//
//  AutoShielding.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 6/25/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine
import ZcashLightClientKit

enum AutoShieldingResult {
    case notNeeded
    case shielded(pendingTx: PendingTransactionEntity)
}

protocol ShieldingCapable: AnyObject {
    /**
    Sends zatoshi.
    - Parameter spendingKey: the key that allows to spend transaprent funds from the given account
    - Parameter memo: the optional memo to include as part of the transaction.
    */
    func shieldFunds(
        spendingKey: UnifiedSpendingKey,
        memo: Memo,
        shieldingThreshold: Zatoshi
    ) async throws -> PendingTransactionEntity
}

protocol AutoShieldingStrategy {
    var shouldAutoShield: Bool { get }
    var shieldingThreshold: Zatoshi { get }
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult
}

protocol UserSession {
    var didFirstSync: Bool { get }
    var alreadyAutoShielded: Bool { get }
    func markFirstSync()
    func markAutoShield()
}

protocol ShieldingKeyProviding {
    func getShieldingKey() throws -> UnifiedSpendingKey
}

protocol TransparentBalanceProviding {
    var transparentFunds: WalletBalance { get }
}

class Session: UserSession {
    
    private init(){}
    
    static var unique = Session()
    private(set) var didFirstSync: Bool = false
    private(set) var alreadyAutoShielded: Bool = false
    
    func markFirstSync() {
        didFirstSync = true
    }
    
    func markAutoShield() {
        alreadyAutoShielded = true
    }
}

protocol AutoShielder: AnyObject {
    var keyProviding: ShieldingKeyProviding {get }
    var strategy: AutoShieldingStrategy { get }
    var shielder: ShieldingCapable { get }
    var keyDeriver: KeyDeriving { get }
    func shield() async throws -> AutoShieldingResult
}

extension AutoShielder {
    func shield() async throws -> AutoShieldingResult {
        guard strategy.shouldAutoShield else {
            return .notNeeded
        }

        let usk = try self.keyProviding.getShieldingKey()

        let memo = try Memo(string: "Shielding from your account: \(usk.account)")

        return await .shielded(
            pendingTx: try self.shielder.shieldFunds(
                spendingKey: usk,
                memo: memo,
                shieldingThreshold: self.strategy.shieldingThreshold
            )
        )
    }
}

class ConcreteAutoShielder: AutoShielder {

    var keyDeriver: KeyDeriving
    
    var shielder: ShieldingCapable
    var strategy: AutoShieldingStrategy
    var keyProviding: ShieldingKeyProviding
    
    init(autoShielding: AutoShieldingStrategy,
         keyProviding: ShieldingKeyProviding,
         keyDeriver: KeyDeriving,
         shielder: ShieldingCapable) {
        self.strategy = autoShielding
        self.keyProviding = keyProviding
        self.shielder = shielder
        self.keyDeriver = keyDeriver
    }
}

class ThresholdDrivenAutoShielding: AutoShieldingStrategy {
    
    var shouldAutoShield: Bool {
        // Shields after first sync, once per session.
        let didFirstSync = session.didFirstSync
        let haventAlreadyAutoshielded = !session.alreadyAutoShielded
        let overThreshold = transparentBalanceProvider.transparentFunds.verified >= threshold
        return didFirstSync && haventAlreadyAutoshielded && overThreshold
    }

    var shieldingThreshold: Zatoshi { threshold }
    
    var session: UserSession
    var threshold: Zatoshi
    var transparentBalanceProvider: TransparentBalanceProviding

    init(session: UserSession,
         threshold zatoshiThreshold: Zatoshi,
         tBalance: TransparentBalanceProviding) {
        self.session = session
        self.threshold = zatoshiThreshold
        self.transparentBalanceProvider = tBalance
    }
    
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        // this strategy attempts to shield once per session, regardless of the result.
        try await autoShielder.shield()
    }
}

class ManualShielding: AutoShieldingStrategy {
    var shieldingThreshold: Zatoshi {
        ZCASH_NETWORK.constants.defaultFee(for: .max)
    }

    var shouldAutoShield: Bool {
        true
    }
    
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        try await autoShielder.shield()
    }
}

class AutoShieldingBuilder {
    static func manualShielder(keyProvider: ShieldingKeyProviding,
                               shielder: ShieldingCapable) -> AutoShielder {
        
        return ConcreteAutoShielder(autoShielding: ManualShielding(),
                                    keyProviding: keyProvider,
                                    keyDeriver: DerivationTool(networkType: ZCASH_NETWORK.networkType),
                                    shielder: shielder)
    }
    
    static func thresholdAutoShielder(keyProvider: ShieldingKeyProviding,
                                      shielder: ShieldingCapable,
                                      threshold: Int64,
                                      balanceProviding: TransparentBalanceProviding) -> AutoShielder {
        
        return ConcreteAutoShielder(
            autoShielding: ThresholdDrivenAutoShielding(session: Session.unique,
                                                        threshold: Zatoshi(threshold),
                                                        tBalance: balanceProviding),
            keyProviding: keyProvider,
            keyDeriver: DerivationTool(networkType: ZCASH_NETWORK.networkType),
            shielder: shielder)
    }
}

extension SDKSynchronizer: ShieldingCapable {}

class DefaultShieldingKeyProvider: ShieldingKeyProviding {
    func getShieldingKey() throws -> UnifiedSpendingKey {
        let derivationTool = DerivationTool(networkType: ZCASH_NETWORK.networkType)
        let s = try SeedManager.default.exportPhrase()
        let seed = try MnemonicSeedProvider.default.toSeed(mnemonic: s)
        return try derivationTool.deriveUnifiedSpendingKey(seed: seed, accountIndex: 0)
    }
}

extension CombineSynchronizer: TransparentBalanceProviding {
    var transparentFunds: WalletBalance {
        self.transparentBalance.value
    }
}
