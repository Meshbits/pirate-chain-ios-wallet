//
//  walletTests.swift
//  walletTests
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import XCTest
@testable import ECC_Wallet_Testnet
import MnemonicSwift
@testable import ZcashLightClientKit
class walletTests: XCTestCase {

    func testReplyToMemo() throws {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6"
        XCTAssertNoThrow(try SendFlowEnvironment.includeReplyTo(recipient: try Recipient(replyTo, network: .testnet), ownAddress: UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm"), in: memo))
    }
    
    func testOnlyReplyToMemo() throws {
        let memo = ""
        let replyTo = UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm")

        // the recipient address is just to determine the type that must be included.
        let replyToMemo = try SendFlowEnvironment.buildMemo(recipient: try Recipient("u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm", network: .mainnet), memo: memo, includesMemo: true, replyToAddress: replyTo)

        let expected = memo + "\nReply-To: \(replyTo.stringEncoded)"

        if case .text(let memoText) = replyToMemo {
            XCTAssertEqual(memoText.string, expected)
        } else {
            XCTFail("Memo is not `.text`")
        }
    }
    
    func testReplyToHugeMemo() throws {
        let memo = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments!"
        let replyTo = "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm"
        let replyToMemo = try SendFlowEnvironment.includeReplyTo(recipient: try Recipient("u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm", network: .mainnet), ownAddress: UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm"), in: memo)
        
        let trimmedExpected = "Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Happy Birthday! Have fun spending these ZEC! visit https://paywithz.cash to know all the places that take ZEC payments! Ha"
        let expected = trimmedExpected + "\nReply-To: \(replyTo)"

        if case .text(let memoText) = replyToMemo {
            XCTAssertEqual(memoText.string, expected)
        } else {
            XCTFail("Memo is not `.text`")
        }
    }
    
    func testKeyPadDecimalLimit() {
        let keyPadViewModel = KeyPadViewModel(value: .constant(""))
        
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("hello world"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("0.0"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("100000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0000000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1000000.0000000"))
        XCTAssertFalse(keyPadViewModel.hasEightOrMoreDecimals("1.0000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("1.00000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.000000001"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.000000000"))
        XCTAssertTrue(keyPadViewModel.hasEightOrMoreDecimals("0.0000000000"))
        
    }
    
    func testMnemonics() throws {
        
        let phrase = try Mnemonic.generateMnemonic(strength: 256)

        
        XCTAssertTrue(phrase.split(separator: " ").count == 24)
        
        XCTAssertNotNil(try Mnemonic.deterministicSeedString(from: phrase),"could not generate seed from phrase: \(phrase)")
        
    }
    
    
    func testRestore() throws {
        let expectedSeed =    "715b4b7950c2153e818f88122f8e54a00e36c42e47ba9589dc82fcecfc5b7ec7d06f4e3a3363a0221e06f14f52e03294290139d05d293059a55076b7f37d6726"
           
        let phrase = "abuse fee wage robot october tongue utility gloom dizzy best victory armor second share pilot help cotton mango music decorate scheme mix tell never"
        
        XCTAssertEqual(try MnemonicSeedProvider.default.toSeed(mnemonic: phrase).hexString,expectedSeed)
    }
    
    func testAddressSlicing() {
        let address = "zs1gn2ah0zqhsxnrqwuvwmgxpl5h3ha033qexhsz8tems53fw877f4gug353eefd6z8z3n4zxty65c"
                
        let split = address.slice(into: 8)
        
        XCTAssert(split.count == 8)
    }
    func testCompatibility() throws {
        let words = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        let hex = "f4e3d38d9c244da7d0407e19a93c80429614ee82dcf62c141235751c9f1228905d12a1f275f5c22f6fb7fcd9e0a97f1676e0eec53fdeeeafe8ce8aa39639b9fe"
        
        XCTAssertNoThrow(try MnemonicSeedProvider.default.isValid(mnemonic: words))
        XCTAssertEqual(try MnemonicSeedProvider.default.toSeed(mnemonic: words).hexString, hex)
    }
    
    func testBuildMemo() throws {
        let memo = "this is a test memo"
        let addr = UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm")
        let expected = "\(memo)\nReply-To: \(addr.stringEncoded)"

        let replyToMemo = try SendFlowEnvironment.buildMemo(recipient: try Recipient("u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm", network: .mainnet), memo: memo, includesMemo: true, replyToAddress: UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm"))

        if case .text(let memoText) = replyToMemo {
            XCTAssertEqual(expected, memoText.string)
        } else {
            XCTFail("Memo is not `.text`")
        }

        XCTAssertEqual(.empty, try SendFlowEnvironment.buildMemo(recipient: try Recipient("u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm", network: .mainnet), memo: "", includesMemo: false, replyToAddress: UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm")))

        XCTAssertEqual(.empty, try SendFlowEnvironment.buildMemo(recipient: try Recipient("u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm", network: .mainnet), memo: memo, includesMemo: false, replyToAddress: UnifiedAddress(validatedEncoding: "u1z9vyk0d0h2k2jwuuk2gfvh5p65qsagkwcgqm6lvh8ratkzjau7stq5snlnkl0eutr687f3wcyn8a0m3n3462c0e4t4cs7m3lvumj2ddm")))
    }
    
    func testBlockExplorerUrl() {
        let txId = "4fd71c6363ac451674ae117f98e8225e0d4d1de67d44091287e62ba0ccf5358b"
        let expectedMainnetURL = "https://blockchair.com/zcash/transaction/\(txId)"
        let expectedTestnetURL = "https://explorer.testnet.z.cash/tx/\(txId)"
        
        let mainnetURL = UrlHandler.blockExplorerURLMainnet(for: txId)?.absoluteString
        let testnetURL = UrlHandler.blockExplorerURLTestnet(for: txId)?.absoluteString
        
        XCTAssertEqual(mainnetURL, expectedMainnetURL)
        XCTAssertEqual(testnetURL, expectedTestnetURL)
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
