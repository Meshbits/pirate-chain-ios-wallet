//
//  ZECCWalletEnvironment.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI
import ZcashLightClientKit
import Combine

enum WalletState {
    case uninitialized
    case unprepared
    case initalized
    case syncing
    case synced
    case failure(error: Error)
}


final class ZECCWalletEnvironment: ObservableObject {

    
    static let genericErrorMessage = "An error ocurred, please check your device logs".localized()
    static let autoShieldingThresholdInZatoshi: Int64 = Int64(ZcashSDK.zatoshiPerZEC / 100)

    static var shared: ZECCWalletEnvironment = try! ZECCWalletEnvironment() // app can't live without this existing.
    static let memoLengthLimit: Int = 512
    static let defaultLightWalletEndpoint = ZcashSDK.isMainnet ? "lightd1.pirate.black" : "testlightd.pirate.black" //"lightd.pirate.black"
    static let defaultLightWalletPort: Int = 443
//    static let defaultFee = 10_000 // Earlier we have used ZcashSDK.defaultFee()
    @Published var state: WalletState
    
    let endpoint = LightWalletEndpoint(address: SeedManager.default.exportLightWalletEndpoint(), port: Int(SeedManager.default.exportLightWalletPort()) ?? defaultLightWalletPort, secure: true)

    var dataDbURL: URL
    var cacheDbURL: URL
    var pendingDbURL: URL
    var outputParamsURL: URL
    var spendParamsURL: URL
    var synchronizer: CombineSynchronizer!
    var autoShielder: AutoShielder!
    var cancellables = [AnyCancellable]()
    var shouldShowAutoShieldingNotice: Bool {
        shouldShowAutoShieldingNoticeScreen()
    }
//    var shieldingAddress: String {
//        synchronizer.unifiedAddress.tAddress
//    }
    #if ENABLE_LOGGING
    var shouldShowFeedbackDialog: Bool { shouldShowFeedbackRequest() }
    #endif
    
    
    static func getInitialState() -> WalletState {
        
        do {
            // are there any keys?
            let keysPresent = SeedManager.default.keysPresent
        
            let databaseFilesPresent = try dbFilesPresent()
            
            switch (keysPresent,databaseFilesPresent) {
            case (false, false):
                return .uninitialized
            case (false, true):
                return .failure(error: WalletError.initializationFailed(message: "This wallet has Db Files but no keys."))
            case (true, false):
                return .unprepared
            case (true, true):
                return .initalized
            }
        } catch {
            tracker.track(.error(severity: .critical), properties: [
                            ErrorSeverity.underlyingError : "error",
                            ErrorSeverity.messageKey : "exception thrown when getting initial state"
            ])
            return .failure(error: error)
        }
    }
    
    static func dbFilesPresent() throws -> Bool  {
        do {
            let fileManager = FileManager()
            
            let dataDbURL = try URL.dataDbURL()
            let attrs = try fileManager.attributesOfItem(atPath: dataDbURL.path)
            return attrs.count > 0 ? true : false
        } catch  CocoaError.fileNoSuchFile, CocoaError.fileReadNoSuchFile  {
            return false
        } catch {
            throw error
        }
        
    }
    
    private init() throws {
        self.dataDbURL = try URL.dataDbURL()
        self.cacheDbURL = try URL.cacheDbURL()
        self.pendingDbURL = try URL.pendingDbURL()
        self.outputParamsURL = try URL.outputParamsURL()
        self.spendParamsURL = try  URL.spendParamsURL()
        self.state = .unprepared
    }
    
    // Warning: Use with care
    func reset() throws {
        if (UIApplication.shared.applicationState == .background){
            NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
        }
        self.synchronizer.stop()
        self.state = Self.getInitialState()
        self.synchronizer = nil
    }
    
    func createNewWallet() async throws {
        
        do {
            let randomPhrase = try MnemonicSeedProvider.default.randomMnemonic()
            
            let birthday = BlockHeight.ofLatestCheckpoint(network: ZCASH_NETWORK)  //WalletBirthday.birthday(with: BlockHeight.max, network: ZCASH_NETWORK)
            
            try SeedManager.default.importBirthday(birthday)
            
            try SeedManager.default.importPhrase(bip39: randomPhrase)
            
            SeedManager.default.importLightWalletEndpoint(address: ZECCWalletEnvironment.defaultLightWalletEndpoint)
            
            SeedManager.default.importLightWalletPort(port: ZECCWalletEnvironment.defaultLightWalletPort)
           
            try await self.initialize()
        
        } catch {
            throw WalletError.createFailed(underlying: error)
        }
    }
    
    func createNewWalletWithPhrase(randomPhrase:String) async throws {
        
        do {
           
            let birthday = BlockHeight.ofLatestCheckpoint(network: ZCASH_NETWORK)
            
            if randomPhrase.isEmpty {
                let mPhrase = try MnemonicSeedProvider.default.randomMnemonic()
                try SeedManager.default.importPhrase(bip39: mPhrase)
            }else{
                try SeedManager.default.importPhrase(bip39: randomPhrase)
            }
            
            try SeedManager.default.importBirthday(birthday)
             
            SeedManager.default.importLightWalletEndpoint(address: ZECCWalletEnvironment.defaultLightWalletEndpoint)
            SeedManager.default.importLightWalletPort(port: ZECCWalletEnvironment.defaultLightWalletPort)
            try await self.initialize()
        
        } catch {
            throw WalletError.createFailed(underlying: error)
        }
    }
    
    func initialize() async throws {
        let seedPhrase = try SeedManager.default.exportPhrase()
        let seedBytes = try MnemonicSeedProvider.default.toSeed(mnemonic: seedPhrase)
//        let viewingKeys = try DerivationTool(networkType: ZCASH_NETWORK.networkType).deriveUnifiedViewingKeysFromSeed(seedBytes, numberOfAccounts: 1)
        
        let viewingKeys = try DerivationTool(networkType: ZCASH_NETWORK.networkType)
            .deriveUnifiedSpendingKey(seed: seedBytes, accountIndex: 0)
            .deriveFullViewingKey()
        
        let initializer = Initializer(
            cacheDbURL: self.cacheDbURL,
            dataDbURL: self.dataDbURL,
            pendingDbURL: self.pendingDbURL,
            endpoint: endpoint,
            network: ZCASH_NETWORK,
            spendParamsURL: self.spendParamsURL,
            outputParamsURL: self.outputParamsURL,
            viewingKeys: [viewingKeys],
            walletBirthday: try SeedManager.default.exportBirthday(),
            loggerProxy: logger)
        
        self.synchronizer = try CombineSynchronizer(initializer: initializer)
        self.autoShielder = AutoShieldingBuilder.thresholdAutoShielder(
            keyProvider: DefaultShieldingKeyProvider(),
            shielder: self.synchronizer.synchronizer,
            threshold: Self.autoShieldingThresholdInZatoshi,
            balanceProviding: self.synchronizer)
        try await self.synchronizer.prepare(with: seedBytes)
        
        self.subscribeToApplicationNotificationsPublishers()
        
//        fixPendingTransactionsIfNeeded()
//
//        try self.synchronizer.start()
        
        try await MainActor.run {
           try self.synchronizer.start()
        }
    }
    
    /**
     only for internal use
     */
    func nuke(abortApplication: Bool = false) {
        if self.synchronizer != nil {
            self.synchronizer.stop()
        }
        
        SeedManager.default.nukeWallet()
        
        do {
            try deleteWalletFiles()
        }
        catch {
            logger.error("could not nuke wallet: \(error)")
        }
        

//        if abortApplication {
//            abort()
//        }
        
    }
    
    func deleteWalletFiles() throws {
        if self.synchronizer != nil {
            self.synchronizer.stop()
        }
        do {
            try FileManager.default.removeItem(at: self.dataDbURL)
            try FileManager.default.removeItem(at: self.cacheDbURL)
            try FileManager.default.removeItem(at: self.pendingDbURL)
        } catch {
            logger.error("could not wipe wallet: \(error)")
            throw WalletError.criticalError(error: error)
        }
    }
    
    /**
     Deletes the wallet's files but keeps the user's keys
     */
    func wipe(abortApplication: Bool = true) throws {
        try deleteWalletFiles()
        
        if abortApplication {
            abort()
        }
        
    }
    
    
    
    static func mapError(error: Error) -> WalletError {
        if let walletError = error as? WalletError {
            return walletError
        }
        /*else if let rustError = error as? RustWeldingError {
            switch rustError {
            case .genericError(let message):
                return WalletError.genericErrorWithMessage(message: message)
            case .dataDbInitFailed(let message):
                return WalletError.initializationFailed(message: message)
            case .dataDbNotEmpty:
                return WalletError.initializationFailed(message: "attempt to initialize a db that was not empty".localized())
            case .saplingSpendParametersNotFound:
                return WalletError.createFailed(underlying: rustError)
            case .malformedStringInput:
                return WalletError.genericErrorWithError(error: rustError)
            default:
                return WalletError.genericErrorWithError(error: rustError)
            }
        }*/
        else if let synchronizerError = error as? SynchronizerError {
            switch synchronizerError {
            case .lightwalletdValidationFailed(let underlyingError):
                return WalletError.criticalError(error: underlyingError)
            case .notPrepared:
                return WalletError.initializationFailed(message: "attempt to initialize an unprepared synchronizer".localized())
            case .generalError(let message):
                return WalletError.genericErrorWithMessage(message: message)
            case .initFailed(let message):
                return WalletError.initializationFailed(message: "Synchronizer failed to initialize: \(message)")
            case .syncFailed:
                return WalletError.synchronizerFailed
            case .connectionFailed(let error):
                return WalletError.connectionFailedWithError(error: error)
            case .maxRetryAttemptsReached(attempts: let attempts):
                return WalletError.maxRetriesReached(attempts: attempts)
            case .connectionError:
              return WalletError.connectionFailed
            case .networkTimeout:
                return WalletError.networkTimeout
            case .uncategorized(let underlyingError):
                return WalletError.genericErrorWithError(error: underlyingError)
            case .criticalError:
                return WalletError.criticalError(error: synchronizerError)
            case .parameterMissing(let underlyingError):
                return WalletError.sendFailed(error: underlyingError)
            case .rewindError(let underlyingError):
                return WalletError.genericErrorWithError(error: underlyingError)
            case .rewindErrorUnknownArchorHeight:
                return WalletError.genericErrorWithMessage(message: "unable to rescan to specified height".localized())
            case .invalidAccount:
                return WalletError.genericErrorWithMessage(message: "your wallet asked a balance for an account index that is not derived. This is probably a programming mistake.".localized())
            }
        } else if let serviceError = error as? LightWalletServiceError {
            switch serviceError {
            case .criticalError:
                return WalletError.criticalError(error: serviceError)
            case .userCancelled:
                return WalletError.connectionFailed
            case .unknown:
                return WalletError.connectionFailed
            case .failed:
                return WalletError.connectionFailedWithError(error: error)
            case .generalError:
                return WalletError.connectionFailed
            case .invalidBlock:
                return WalletError.genericErrorWithError(error: error)
            case .sentFailed(let error):
                return WalletError.sendFailed(error: error)
            case .genericError(error: let error):
                return WalletError.genericErrorWithError(error: error)
            case .timeOut:
                return WalletError.networkTimeout
            }
        }
        
        return WalletError.genericErrorWithError(error: error)
    }
    deinit {
        cancellables.forEach {
            c in
            c.cancel()
        }
    }
    
    
    // Mark: handle background activity
    
    var appCycleCancellables = [AnyCancellable]()
    
    var taskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    private var isBackgroundAllowed: Bool {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            return true
        default:
            return false
        }
    }
    
    private var isSubscribedToAppDelegateEvents = false
    private var shouldRetryRestart = false
    private func registerBackgroundActivity() {
        if self.taskIdentifier == .invalid {
            
            let isSynced = (self.synchronizer.syncStatus.value == .synced) ? true : false
            
            self.taskIdentifier = UIApplication.shared.beginBackgroundTask(withName: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifierARRR, expirationHandler: { [weak self, weak logger] in
                logger?.info("BackgroundTask Expiration Handler Called")
                guard let self = self else { return }
                self.synchronizer.stop()
                self.shouldRetryRestart = true
                self.invalidateBackgroundActivity()
                NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
            })
            
            if !isSynced {
                NotificationCenter.default.post(name: NSNotification.Name(mPlaySoundWhileSyncing), object: nil)
            }
        }
    }
    
    private func invalidateBackgroundActivity() {
        guard self.taskIdentifier != .invalid else {
            return
        }
        UIApplication.shared.endBackgroundTask(self.taskIdentifier)
        self.taskIdentifier = .invalid
    }
    
    func subscribeToApplicationNotificationsPublishers() {
        self.isSubscribedToAppDelegateEvents = true
        let center = NotificationCenter.default
        
        center.publisher(for: UIApplication.willEnterForegroundNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self, weak logger] _ in
                
                logger?.debug("applicationWillEnterForeground")
                guard let self = self else { return }
                
                self.invalidateBackgroundActivity()
                do {
                    try self.synchronizer.start(retry: self.shouldRetryRestart)
                    self.shouldRetryRestart = false
                } catch {
                    logger?.debug("applicationWillEnterForeground --> Error restarting: \(error)")
                }
                
                
            }
            .store(in: &appCycleCancellables)
        
        center.publisher(for: UIApplication.didBecomeActiveNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak logger] _ in
                logger?.debug("didBecomeActiveNotification")
            }
            .store(in: &appCycleCancellables)
        center.publisher(for: UIApplication.didEnterBackgroundNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self, weak logger] _ in
                self?.registerBackgroundActivity()
                logger?.debug("didEnterBackgroundNotification")
            }
            .store(in: &appCycleCancellables)
        center.publisher(for: UIApplication.willResignActiveNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak logger] _ in
               
                logger?.debug("applicationWillResignActive")
            }
            .store(in: &appCycleCancellables)
        
        center.publisher(for: UIApplication.willTerminateNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if (UIApplication.shared.applicationState == .background){
                    NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
                }
                self?.synchronizer.stop()
            }
            .store(in: &appCycleCancellables)
        
    }
    
    func unsubscribeFromApplicationNotificationsPublishers() {
        self.isSubscribedToAppDelegateEvents = false
        self.appCycleCancellables.forEach { $0.cancel() }
    }
}

extension ZECCWalletEnvironment {
    
    static var appName: String {
        if ZcashSDK.isMainnet {
            return "Pirate Chain Wallet".localized()
        } else {
            return "ECC Testnet"
        }
    }
    
    static var appBuild: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var appVersion: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func isValidShieldedAddress(_ address: String) -> Bool {
        address.isValidShieldedAddress
    }
    
    func isValidTransparentAddress(_ address: String) -> Bool {
        address.isValidTransparentAddress
    }
    
    func isValidAddress(_ address: String) -> Bool {
        address.isValidAddress
    }
    func sufficientFundsToSend(amount: Double) -> Bool {
        return sufficientFunds(availableBalance: getShieldedBalance(), zatoshiToSend: amount.toZatoshi())
    }
    
    private func sufficientFunds(availableBalance: Int64, zatoshiToSend: Int64) -> Bool {
        availableBalance - zatoshiToSend  - Int64(ZCASH_NETWORK.constants.defaultFee().amount) >= 0
    }
    
    static var minerFee: Double {
        ZCASH_NETWORK.constants.defaultFee().decimalValue.doubleValue
    }
    
    func credentialsAlreadyPresent() -> Bool {
        (try? SeedManager.default.exportPhrase()) != nil
    }
    
    func getShieldedVerifiedBalance() -> Int64 {
        self.synchronizer.initializer.getVerifiedBalance().amount
    }
    
    func getShieldedBalance() -> Int64 {
        self.synchronizer.initializer.getBalance().amount
    }
    
    func getShieldedAddress() async -> UnifiedAddress? {
        await self.synchronizer.synchronizer.getUnifiedAddress(accountIndex: 0)
    }
}


fileprivate struct WalletEnvironmentKey: EnvironmentKey {
    static let defaultValue: ZECCWalletEnvironment = ZECCWalletEnvironment.shared
}

extension EnvironmentValues {
    var walletEnvironment: ZECCWalletEnvironment  {
        get {
            self[WalletEnvironmentKey.self]
        }
        set {
            self[WalletEnvironmentKey.self] = newValue
        }
    }
}

extension View {
    func walletEnvironment(_ env: ZECCWalletEnvironment) -> some View {
        environment(\.walletEnvironment, env)
    }
}

extension ZECCWalletEnvironment {
    func shouldShowAutoShieldingNoticeScreen() -> Bool {
        return !UserSettings.shared.didShowAutoShieldingNotice
    }
    
    func registerAutoShieldingNoticeScreenShown() {
        UserSettings.shared.didShowAutoShieldingNotice = true
    }
}

#if ENABLE_LOGGING
extension ZECCWalletEnvironment {
    func shouldShowFeedbackRequest() -> Bool {
        
        guard let lastDate = UserSettings.shared.lastFeedbackDisplayedOnDate else {
            return true
        }
        let now = Date()
        
        let calendar = Calendar.current
        
        return (calendar.dateComponents([.day], from: lastDate, to: now).day ?? 0) > 1
        
    }
    
    func registerFeedbackSolicitation(on date: Date) {
        UserSettings.shared.lastFeedbackDisplayedOnDate = date
    }
}
#endif


extension ZcashSDK {
    static var isMainnet: Bool {
        switch ZCASH_NETWORK.networkType {
        case .mainnet:
            return true
        case .testnet:
            return false
        }
    }
}
