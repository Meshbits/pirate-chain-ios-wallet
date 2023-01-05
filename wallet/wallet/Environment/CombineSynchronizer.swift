//
//  CombineSynchronizer.swift
//  wallet
//
//  Created by Francisco Gindre on 1/27/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import ZcashLightClientKit
class CombineSynchronizer {
    enum SubscriberErrors: Error {
        case notifactionMissingValueForKey(_ key: String)
    }
    
    var initializer: Initializer {
        synchronizer.initializer
    }
    var unifiedAddress: UnifiedAddress! // FIXMME: There's no sense of a key-less synchronizer
    private(set) var synchronizer: SDKSynchronizer
    var walletDetailsBuffer: CurrentValueSubject<[DetailModel],Never>
    var connectionState: CurrentValueSubject<ConnectionState,Never>
    var syncStatus: CurrentValueSubject<SyncStatus,Never>
    var syncBlockHeight: CurrentValueSubject<BlockHeight,Never>
    var minedTransaction = PassthroughSubject<PendingTransactionEntity,Never>()
    var shieldedBalance: CurrentValueSubject<WalletBalance, Never>
    var transparentBalance: CurrentValueSubject<WalletBalance, Never>

    var cancellables = [AnyCancellable]()
    var errorPublisher = PassthroughSubject<Error, Never>()
    
    var receivedTransactions: Future<[ConfirmedTransactionEntity],Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.receivedTransactions))
            }
        }
    }
    
    var sentTransactions: Future<[ConfirmedTransactionEntity], Never> {
        Future<[ConfirmedTransactionEntity], Never>() {
            promise in
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                promise(.success(self.synchronizer.sentTransactions))
            }
        }
    }
    
    var pendingTransactions: Future<[PendingTransactionEntity], Never> {
        
        Future<[PendingTransactionEntity], Never>(){
            [weak self ] promise in
            
            guard let self = self else {
                promise(.success([]))
                return
            }
            
            DispatchQueue.global().async {
                promise(.success(self.synchronizer.pendingTransactions))
            }
        }
    }
    
    var latestHeight: Future<BlockHeight,Error> {
        Future<BlockHeight,Error>() {
            [weak self ] promise in
            
            guard let self = self else { return }
            self.synchronizer.latestHeight { (result) in
                switch result {
                case .success(let height):
                    promise(.success(height))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    init(initializer: Initializer) throws {
        self.walletDetailsBuffer = CurrentValueSubject([DetailModel]())
        self.synchronizer = try SDKSynchronizer(initializer: initializer)
        self.syncStatus = CurrentValueSubject(.disconnected)
        self.shieldedBalance = CurrentValueSubject(WalletBalance(verified: .zero, total: .zero))
        let transparentSubject = CurrentValueSubject<WalletBalance, Never>(WalletBalance(verified: .zero, total: .zero))
        self.transparentBalance = transparentSubject
        self.syncBlockHeight = CurrentValueSubject(ZCASH_NETWORK.constants.saplingActivationHeight)
        self.connectionState = CurrentValueSubject(self.synchronizer.connectionState)
        
        // Subscribe to SDKSynchronizer notifications
        
        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] notification in
                guard let self = self else { return }
                guard let userInfo = notification.userInfo else {
                    logger.error("Received `.synchronizerSynced` but the userInfo is empty")
                    Task { @MainActor in
                        await self.updatePublishers()
                    }
                    return
                }
                
                guard let synchronizerState = userInfo[SDKSynchronizer.NotificationKeys.synchronizerState] as? SDKSynchronizer.SynchronizerState else {
                    logger.error("Received `.synchronizerSynced` but the userInfo is empty")
                    Task { @MainActor in
                        await self.updatePublishers()
                    }
                    return
                }
                self.updatePublishers(with: synchronizerState)
            }).store(in: &cancellables)
        
        
        NotificationCenter.default.publisher(for: .synchronizerMinedTransaction)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minedNotification in
                guard let self = self else { return }
                guard let minedTx = minedNotification.userInfo?[SDKSynchronizer.NotificationKeys.minedTransaction] as? PendingTransactionEntity else { return }
                self.minedTransaction.send(minedTx)
            }).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .synchronizerFailed)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] (notification) in

                guard let self = self else { return }

                guard let error = notification.userInfo?[SDKSynchronizer.NotificationKeys.error] as? Error else {
                    self.errorPublisher.send(WalletError.genericErrorWithMessage(message: "An error ocurred, but we can't figure out what it is. Please check device logs for more details")
                    )
                    return
                }
                
                self.errorPublisher.send(error)
            }.store(in: &cancellables)

        Publishers.Merge(NotificationCenter.default.publisher(for: .blockProcessorStatusChanged), NotificationCenter.default.publisher(for: .blockProcessorUpdated))
            .receive(on: DispatchQueue.main)
            .compactMap { n -> SyncStatus? in
                guard let userInfo = n.userInfo else {
                    logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey("userInfo"))")
                    return nil }
                
                switch  n.name {
                case .blockProcessorStatusChanged:
                    guard let status = userInfo[CompactBlockProcessorNotificationKey.newStatus] as? CompactBlockProcessor.State else {
                        logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.newStatus))")
                        return nil}
                    return status.syncStatus
                case .blockProcessorUpdated:
                    guard let update = userInfo[CompactBlockProcessorNotificationKey.progress] as? CompactBlockProgress else {
                        logger.error("error: \(SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.progress))")
                        return nil }
                    return update.syncStatus
                default:
                    return nil
                }
                
            }
            .sink(receiveValue: { [weak self] status in
                self?.syncStatus.send(status)
            })
            .store(in: &cancellables)


        NotificationCenter.default.publisher(for: .blockProcessorUpdated)
            .receive(on: DispatchQueue.main)
            .map { notification -> CompactBlockProgress? in
                
                guard let progress = notification.userInfo?[CompactBlockProcessorNotificationKey.progress] as? CompactBlockProgress else {
                    let error = SubscriberErrors.notifactionMissingValueForKey(CompactBlockProcessorNotificationKey.progress)
                    
                    tracker.report(handledException: error)
                    return nil
                }
                
                return progress
            }

            .compactMap({ progress -> SyncStatus? in
                
                switch progress {

                case .download(let progressReport):
                    return SyncStatus.downloading(progressReport)
                case .validate:
                    return .validating
                case .scan(let progressReport):
                    return .scanning(progressReport)
                case .enhance(let enhancingReport):
                    return .enhancing(enhancingReport)
                case .fetch:
                    return .fetching
                case .none:
                    return nil
                }
            })

            .sink(receiveValue: { [weak self] status in
                self?.syncStatus.send(status)
            })
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .synchronizerConnectionStateChanged)
            .compactMap { notification -> ConnectionState? in
                guard let connectionState = notification.userInfo?[SDKSynchronizer.NotificationKeys.currentConnectionState] as? ConnectionState else {
                    return nil
                }
                return connectionState
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.connectionState.send(value)
            })
            .store(in: &cancellables)
    }
    
    func prepare(with seedBytes: [UInt8]?) async throws {
        // TODO: handle two-step prepare
        let initDbResult = try self.synchronizer.prepare(with: seedBytes)

        guard initDbResult == Initializer.InitializationResult.success else {
            throw SynchronizerError.initFailed(message: "Seed is require to initialize")
        }

        self.unifiedAddress = await self.synchronizer.getUnifiedAddress(accountIndex: 0)
        
        // BUGFIX: transactions history empty when synchronizer fails to connect to server
        // fill with initial values
        await self.updatePublishers()
    }
    
    func start(retry: Bool = false) throws {
        do {
            if retry {
                stop()
            }
            try synchronizer.start(retry: retry)
        } catch {
            logger.error("error starting \(error)")
            throw error
        }
    }
    
    func stop() {
        synchronizer.stop()
    }
    
    func cancel(pendingTransaction: PendingTransactionEntity) -> Bool {
        synchronizer.cancelSpend(transaction: pendingTransaction)
    }
    
    func rewind(_ policy: RewindPolicy) async throws {
        try await synchronizer.rewind(policy)
    }

    func updatePublishers(with state: SDKSynchronizer.SynchronizerState) {
        self.transparentBalance.send(state.transparentBalance)
        self.shieldedBalance.send(state.shieldedBalance)
        self.syncStatus.send(state.syncStatus)
        self.syncBlockHeight.send(state.latestScannedHeight)
        self.walletDetails.sink(receiveCompletion: { _ in
            }) { [weak self] (details) in
                guard !details.isEmpty else { return }
                self?.walletDetailsBuffer.send(details)
        }
        .store(in: &self.cancellables)
    }

    func updatePublishers() async {
        let tBalance = (try? await synchronizer.getTransparentBalance(accountIndex: 0)) ?? WalletBalance.zero
        self.transparentBalance.send(tBalance)

        let shieldedVerifiedBalance: Zatoshi = synchronizer.getShieldedVerifiedBalance()
        let shieldedTotalBalance: Zatoshi = synchronizer.getShieldedBalance(accountIndex: 0)
        
        self.shieldedBalance.send(WalletBalance(verified: shieldedVerifiedBalance, total: shieldedTotalBalance))
        self.syncStatus.send(synchronizer.status)
        self.walletDetails.sink(receiveCompletion: { _ in
            }) { [weak self] (details) in
                guard !details.isEmpty else { return }
                self?.walletDetailsBuffer.send(details)
        }
        .store(in: &self.cancellables)
    }
    
    deinit {
        synchronizer.stop()
        for c in cancellables {
            c.cancel()
        }
    }
    
    func send(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) async throws -> PendingTransactionEntity {
        let pendingTx = try await self.synchronizer.sendToAddress(
                spendingKey: spendingKey,
                zatoshi: zatoshi,
                toAddress: recipientAddress,
                memo: memo
        )

        await self.updatePublishers()

        return pendingTx
    }
    
    public func shieldFunds(
        spendingKey: UnifiedSpendingKey,
        memo: Memo
    ) async throws -> PendingTransactionEntity {
        try await self.shieldFunds(spendingKey: spendingKey, memo: memo)
    }
}

extension CombineSynchronizer {
    var walletDetails: Future<[DetailModel], Error> {
        Future<[DetailModel],Error>() {
            [weak self] promise in
            guard let self = self else {
                promise(.success([]))
                return
            }
            DispatchQueue.global().async {
                [weak self] in
                guard let self = self else { return }
                var collectables = Set<AnyCancellable>()
                
                do {
                    
                    let blockHeight = self.syncBlockHeight.value
                    let pending = try self.synchronizer.allPendingTransactions().map { DetailModel(pendingTransaction: $0, latestBlockHeight: blockHeight) }
                    
                    let txs = try self.synchronizer.allClearedTransactions().map { DetailModel(confirmedTransaction: $0, sent: ($0.toAddress != nil)) }.filter({ s in
                        pending.first { (p) -> Bool in
                            p.id == s.id
                            } == nil })
      
                    Publishers.Merge( Publishers.Sequence<[DetailModel],Never>(sequence: txs),
                                      Publishers.Sequence<[DetailModel],Never>(sequence: pending)
                    ).collect().sink { details in
                        
                        promise(.success(
                            details.sorted(by: { (a,b) in
                                a.date > b.date
                            })
                            )
                        )
                    }
                    .store(in: &collectables)
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

extension CombineSynchronizer {
    func fullRescan() async {
        do {
            try await self.rewind(.birthday)
            try await MainActor.run {
                try self.start(retry: true)
            }
        } catch {
            logger.error("Full rescan failed \(error)")
        }
    }
    
    func quickRescan() async {
        do {
            try await self.rewind(.quick)
            try await MainActor.run {
                try self.start(retry: true)
            }
        } catch {
            logger.error("Quick rescan failed \(error)")
        }
    }
    
    func getTransparentAddress(account: Int = 0) async -> TransparentAddress? {
        await self.synchronizer.getTransparentAddress(accountIndex: account)
    }
    func getShieldedAddress(account: Int = 0) async -> SaplingAddress? {
        await self.synchronizer.getSaplingAddress(accountIndex: account)
    }
}

extension CompactBlockProcessor.State {
    var syncStatus: SyncStatus? {
        switch self {
        case .stopped:
            return .stopped
        case .downloading:
            return .downloading(.nullProgress)
        case .error(let e):
            return .error(e)
        case .fetching:
            return .fetching
        case .synced:
            return .synced
        case .scanning:
            return .scanning(.nullProgress)
        case .validating:
            return .validating
        case .enhancing:
            return nil
        case .handlingSaplingFiles:
            return nil
        }
    }
}

fileprivate struct NullEnhancementProgress: EnhancementProgress {
    var totalTransactions: Int { 0 }
    var enhancedTransactions: Int { 0 }
    var lastFoundTransaction: ConfirmedTransactionEntity? { nil }
    var range: CompactBlockRange { 0 ... 0 }
}

extension CompactBlockProgress {
    var syncStatus: SyncStatus {
        switch self {
        case .download(let progress):
            return .downloading(progress)
        case .validate:
            return .validating
        case .scan(let progress):
            return .scanning(progress)
        case .enhance(let enhanceProgress):
            return .enhancing(enhanceProgress)
        case .fetch:
            return .fetching
        }
    }
}
