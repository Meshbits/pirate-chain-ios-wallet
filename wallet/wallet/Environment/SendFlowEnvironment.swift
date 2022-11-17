//
//  SendFlowEnvironment.swift
//  wallet
//
//  Created by Francisco Gindre on 1/13/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit
import Combine
import SwiftUI

class SendFlow {
    
    static var current: SendFlowEnvironment?
    
    static func end() {
        guard let current = self.current else {
            return
        }
        
        current.close()
        
        Self.current = nil
    }
    
    @discardableResult static func start(appEnviroment: ZECCWalletEnvironment,
                      isActive: Binding<Bool>,
                      amount: Double) -> SendFlowEnvironment {

        let flow = SendFlowEnvironment(amount: amount,
                                       verifiedBalance: appEnviroment.getShieldedVerifiedBalance().asHumanReadableZecBalance(),
                                       isActive: isActive)
        Self.current = flow
        NotificationCenter.default.post(name: .sendFlowStarted, object: nil)
        return flow
    }
}

final class SendFlowEnvironment: ObservableObject {
    enum FlowState {
        case preparing
        case downloadingParameters
        case sending
        case finished
        case failed(error: UserFacingErrors)
    }

    enum FlowError: Error {
        case memoToTransparentAddress
        case invalidEnvironment
        case duplicateSent
        case failedToDownloadParameters(message: String)
        case invalidAmount(message: String)
        case derivationFailed(error: Error)
        case derivationFailed(message: String)
        case invalidDestinationAddress(address: String)
    }

    static let maxMemoLength: Int = ZECCWalletEnvironment.memoLengthLimit
    
    @Published var showScanView = false
    @Published var amount: String
    @Binding var isActive: Bool
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var includeSendingAddress: Bool = false
    @Published var isDone = false
    @Published var state: FlowState = .preparing
    var txSent = false

    var error: Error?
    var showError = false
    var pendingTx: PendingTransactionEntity?
    var diposables = Set<AnyCancellable>()
    
    fileprivate init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        self.verifiedBalance = verifiedBalance
        self.address = address
        self._isActive = isActive
        
        NotificationCenter.default.publisher(for: .qrZaddressScanned)
                   .receive(on: DispatchQueue.main)
                   .debounce(for: 1, scheduler: RunLoop.main)
                   .sink(receiveCompletion: { (completion) in
                       switch completion {
                       case .failure(let error):
                        tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
                           logger.error("error scanning: \(error)")
                           tracker.track(.error(severity: .noncritical), properties:  [ErrorSeverity.messageKey : "\(error)"])
                           self.error = error
                       case .finished:
                           logger.debug("finished scanning")
                       }
                   }) { (notification) in
                       guard let address = notification.userInfo?["zAddress"] as? String else {
                           return
                       }
                       self.showScanView = false
                       logger.debug("got address \(address)")
                       self.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
                       
               }
               .store(in: &diposables)
    }
    
    deinit {
        diposables.forEach { d in
            d.cancel()
        }
    }

    func clearMemo() {
        self.memo = ""
        self.includeSendingAddress = false
        self.includesMemo = false
    }

    func fail(_ error: Error) {
        self.error = error
        self.showError = true
        self.isDone = true
        self.state = .failed(error: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
    }

    @MainActor
    func preSend() async {
        guard case FlowState.preparing = self.state else {
            let message = "attempt to start a pre-send stage where status was not .preparing and was \(self.state) instead"
            logger.error(message)
            tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : message])
            fail(FlowError.duplicateSent)
            return
        }
        
        self.state = .downloadingParameters
        do {
            let result = try await SaplingParameterDownloader.downloadParamsIfnotPresent(
                spendURL: try URL.spendParamsURL(),
                outputURL: try URL.outputParamsURL()
            )
        } catch SaplingParameterDownloader.Errors.failed(let error) {
            let message = "Failed to download parameters with error: \(error.localizedDescription)"
            tracker.track(
                .error(severity: .critical),
                properties:  [
                    ErrorSeverity.messageKey : message
                ]
            )
            fail(FlowError.failedToDownloadParameters(message: message))
        } catch SaplingParameterDownloader.Errors.invalidURL {
            let message = "Invalid URL was provided"
            tracker.track(
                .error(severity: .critical),
                properties:  [
                    ErrorSeverity.messageKey : message
                ]
            )
            fail(FlowError.failedToDownloadParameters(message: message))
        } catch {
            fail(error)
        }
        await send()
    }
    
    func send() async {

        self.state = .sending

        guard !txSent else {
            let message = "attempt to send tx twice"
            logger.error(message)
            tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : message])
            fail(FlowError.duplicateSent)
            return
        }

        let environment = ZECCWalletEnvironment.shared
        guard let zatoshi = doubleAmount?.toZatoshi() else {
            let message = "invalid zatoshi amount: \(String(describing: doubleAmount))"
            logger.error(message)
            fail(FlowError.invalidAmount(message: message))
            return
        }
            
        do {
            let phrase = try SeedManager.default.exportPhrase()
            let seedBytes = try MnemonicSeedProvider.default.toSeed(mnemonic: phrase)

            let usk = try DerivationTool(networkType: ZCASH_NETWORK.networkType)
                .deriveUnifiedSpendingKey(seed: seedBytes, accountIndex: 0)

           
            guard let replyToAddress = await environment.getShieldedAddress() else {
                let message = "could not derive user's own address"
                logger.error(message)
                await MainActor.run {
                    self.fail(FlowError.derivationFailed(message: "could not derive user's own address"))
                }
                return
            }
    
            UserSettings.shared.lastUsedAddress = self.address

            let memo: Memo?

            let recipient: Recipient = try Recipient(self.address, network: ZCASH_NETWORK.networkType)

            if case .transparent = recipient {
                memo = nil
            } else if self.includeSendingAddress {
                memo = try Self.buildMemo(
                    recipient: recipient,
                    memo: self.memo,
                    includesMemo: self.includesMemo,
                    replyToAddress: replyToAddress
                )
            } else {
                memo = try Memo(string: self.memo)
            }
            
            Future(operation: {
                try await environment.synchronizer.send(
                    with: usk,
                    zatoshi: Zatoshi(zatoshi),
                    to: recipient,
                    memo: memo
                )

            })
             .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] (completion) in
                    guard let self = self else {
                        return
                    }
                    
                    switch completion {
                    case .finished:
                        logger.debug("send flow finished")
                    case .failure(let error):
                        tracker.report(handledException: DeveloperFacingErrors.handledException(error: error))
                        logger.error("\(error)")
                        self.error = error
                        self.showError = true
                        tracker.track(.error(severity: .critical), properties:  [ErrorSeverity.messageKey : "\(ZECCWalletEnvironment.mapError(error: error))"])
                        
                    }
                    // fix me:
                    self.isDone = true
                    
                }) { [weak self] (transaction) in
                    guard let self = self else {
                        return
                    }
                        self.pendingTx = transaction
                    self.state = .finished
                }.store(in: &diposables)

            self.txSent = true
        } catch {
            logger.error("failed to send: \(error)")
            self.fail(error)
        }
    }
    
    var hasErrors: Bool {
        self.error != nil || self.showError
    }
    var hasFailed: Bool {
        isDone && hasErrors
    }
    
    var hasSucceded: Bool {
        isDone && !hasErrors
    }
    
    var doubleAmount: Double? {
        NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue
    }
    func close() {
        self.isActive = false
        NotificationCenter.default.post(name: .sendFlowClosed, object: nil)
    }
    
    static func replyToAddress(to: Recipient, ownAddress: UnifiedAddress) -> String? {
        switch to {
        case .unified:
            return "\nReply-To: \(ownAddress.stringEncoded)"
        case .sapling:
            guard let ownSapling = ownAddress.saplingReceiver() else {
                return nil
            }
            return "\nReply-To: \(ownSapling.stringEncoded)"
        default:
            return nil
        }

    }
    
    static func includeReplyTo(recipient: Recipient, ownAddress: UnifiedAddress, in memo: String, charLimit: Int = SendFlowEnvironment.maxMemoLength) throws -> Memo {

        if case Recipient.transparent = recipient {
            throw SendFlowEnvironment.FlowError.memoToTransparentAddress
        }
        
        guard let replyTo = replyToAddress(to: recipient, ownAddress: ownAddress) else {
            throw SendFlowEnvironment.FlowError.memoToTransparentAddress
        }
        
        if (memo.count + replyTo.count) >= charLimit {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return try Memo(string: truncatedMemo + replyTo)
        }
        return try Memo(string: memo + replyTo)
    }
    
    static func buildMemo(recipient: Recipient, memo: String, includesMemo: Bool, replyToAddress: UnifiedAddress) throws -> Memo {
        
        guard includesMemo else { return .empty }
        
        return try includeReplyTo(
            recipient: recipient,
            ownAddress: replyToAddress,
            in: memo
        )
    }
}

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
    static let sendFlowStarted = Notification.Name("sendFlowStarted")
}

