//
//  AutoShieldingTests.swift
//  ECC-WalletTests
//
//  Created by Francisco Gindre on 6/25/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import XCTest
import Combine
@testable import ZcashLightClientKit
@testable import ECC_Wallet_Testnet
class AutoShieldingTests: XCTestCase {
    func testAutoShield() async throws {
        let mockShielder = MockShielder(
            strategy: MockFailedManualStrategy(),
            shielder: MockSuccessfulShieldingCapable(),
            keyProviding: MockKeyProviding(),
            keyDeriver: MockKeyDeriving()
        )

        do {
            switch try await mockShielder.shield() {
            case .notNeeded:
                XCTFail("manual shielding is always needed")
            case .shielded:
                XCTAssertTrue(true)
            }
        } catch {
            XCTFail("failed with error: \(error)")
            return
        }
    }
    
    func testAutoShieldFails() async throws {
        let mockShielder = MockShielder(
            strategy: MockFailedManualStrategy(),
            shielder: MockFailureShieldingCapable(),
            keyProviding: MockKeyProviding(),
            keyDeriver: MockKeyDeriving()
        )
        
        let expectation = XCTestExpectation(description: "Shield Expectation")

        do {
            switch try await mockShielder.shield() {
            case .notNeeded:
                XCTFail("manual shielding is always needed")
            case .shielded:
                XCTFail("this test should have failed")
            }
        } catch ShieldFundsError.insuficientTransparentFunds {
            XCTAssertTrue(true)
        } catch {
            XCTFail("failed with error: \(error)")
        }
    }
    
    func testAutoShieldNonNeeded() async throws {
        let mockShielder = MockShielder(
            strategy: MockShieldNotNeeded(),
            shielder: MockSuccessfulShieldingCapable(),
            keyProviding: MockKeyProviding(),
            keyDeriver: MockKeyDeriving()
        )

        do {
            switch try await mockShielder.shield() {
            case .notNeeded:
                XCTAssertTrue(true)
            case .shielded:
                XCTFail("this test should have failed")
            }
        } catch {
            XCTFail("failed with error: \(error)")
        }
    }
}


class MockShielder: AutoShielder {
    var keyDeriver: KeyDeriving
    var keyProviding: ShieldingKeyProviding
    var shielder: ShieldingCapable
    var strategy: AutoShieldingStrategy
    
    init(strategy: AutoShieldingStrategy,
         shielder: ShieldingCapable,
         keyProviding: ShieldingKeyProviding,
         keyDeriver: KeyDeriving) {
        self.strategy = strategy
        self.shielder = shielder
        self.keyProviding = keyProviding
        self.keyDeriver = keyDeriver
    }
}

class MockShieldNotNeeded: AutoShieldingStrategy {
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC)
        return .notNeeded
    }
    
    var shouldAutoShield: Bool {
        false
    }
    /**
     throws no UTXO found because this shouldn't be called if autoshield not needed
     */
    func shield() -> Future<AutoShieldingResult, Error> {
        Future<AutoShieldingResult, Error> { promise in
            promise(.failure(ShieldFundsError.noUTXOFound))
        }
    }
}
class MockSuccessfulManualStrategy: AutoShieldingStrategy {
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        return .shielded(pendingTx: MockPendingTx())
    }

    var shouldAutoShield: Bool {
        true
    }
    
}

class MockShieldingNotNeededStrategy: AutoShieldingStrategy {
    /// throws ShieldFundsError.insuficientTransparentFunds) after 2 seconds
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        return AutoShieldingResult.notNeeded
    }

    var shouldAutoShield: Bool {
        false
    }
}
class MockFailedManualStrategy: AutoShieldingStrategy {
    /// throws ShieldFundsError.insuficientTransparentFunds) after 2 seconds
    func shield(autoShielder: AutoShielder) async throws -> AutoShieldingResult {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        throw ShieldFundsError.insuficientTransparentFunds
    }

    var shouldAutoShield: Bool {
        true
    }
}

struct MockPendingTx: PendingTransactionEntity {
    var fee: ZcashLightClientKit.Zatoshi? = Zatoshi(1000)

    var recipient = PendingTransactionRecipient.address(
        try! Recipient(
            "ztestsapling1vsrxjdmfpwz4yn8y8ux72je2hjqc82u28a5ahycsdldtd95d4mfepfmptqk22tsqxcelzmur6rr",
            network: .testnet
        )
    )
    var value = Zatoshi(120000)
    
    var accountIndex: Int = 0
    
    var minedHeight: BlockHeight = -1
    
    var expiryHeight: BlockHeight = 123456780
    
    var cancelled: Int = 0
    
    var encodeAttempts: Int = 1
    
    var submitAttempts: Int = 1
    
    var errorMessage: String? = nil
    
    var errorCode: Int? = nil
    
    var createTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    
    func isSameTransactionId<T>(other: T) -> Bool where T : RawIdentifiable {
        false
    }
    
    var raw: Data? = Data()
    
    var id: Int? = 1
    
    var memo: Data? = nil
    
    var rawTransactionId: Data? = Data()
    
}

class MockSuccessfulShieldingCapable: ShieldingCapable {
    func shieldFunds(spendingKey: UnifiedSpendingKey, memo: Memo) async throws -> PendingTransactionEntity {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 2)
        return MockPendingTx()
    }
}

class MockFailureShieldingCapable: ShieldingCapable {
    func shieldFunds(spendingKey: UnifiedSpendingKey, memo: Memo) async throws -> PendingTransactionEntity {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 2)
        throw ShieldFundsError.insuficientTransparentFunds
    }
}


class MockKeyProviding: ShieldingKeyProviding {
    func getShieldingKey() throws -> ZcashLightClientKit.UnifiedSpendingKey {
        UnifiedSpendingKey(network: .testnet, bytes: [0,0,0], account: 0)
    }
}

enum MockError: Error {
    case notImplemented
}
class MockKeyDeriving: KeyDeriving {
    func deriveUnifiedSpendingKey(seed: [UInt8], accountIndex: Int) throws -> ZcashLightClientKit.UnifiedSpendingKey {
        throw MockError.notImplemented
    }

    static func saplingReceiver(from unifiedAddress: ZcashLightClientKit.UnifiedAddress) throws -> ZcashLightClientKit.SaplingAddress? {
        throw MockError.notImplemented
    }

    static func transparentReceiver(from unifiedAddress: ZcashLightClientKit.UnifiedAddress) throws -> ZcashLightClientKit.TransparentAddress? {
        throw MockError.notImplemented
    }

    static func receiverTypecodesFromUnifiedAddress(_ address: ZcashLightClientKit.UnifiedAddress) throws -> [ZcashLightClientKit.UnifiedAddress.ReceiverTypecodes] {
        throw MockError.notImplemented
    }
}
