//
//  SeedManagement.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import KeychainSwift
import ZcashLightClientKit
final class SeedManager {
    
    enum SeedManagerError: Error {
        case alreadyImported
        case uninitializedWallet
    }
    
    static var `default`: SeedManager = SeedManager()
    private static let zECCWalletKeys = "zECCWalletKeys"
    private static let zECCWalletSeedKey = "zEECWalletSeedKey"
    private static let zECCWalletBirthday = "zECCWalletBirthday"
    private static let zECCWalletPhrase = "zECCWalletPhrase"
    private static let aRRRLightWalletEndpoint = "aRRRLightWalletEndpoint"
    private static let aRRRPincode = "aRRRPinCode"

    private let keychain = KeychainSwift()
    
    func importBirthday(_ height: BlockHeight) throws {
        guard keychain.get(Self.zECCWalletBirthday) == nil else {
            throw SeedManagerError.alreadyImported
        }
        keychain.set(String(height), forKey: Self.zECCWalletBirthday)
    }
    
    func exportBirthday() throws -> BlockHeight {
        guard let birthday = keychain.get(Self.zECCWalletBirthday),
            let value = BlockHeight(birthday) else {
                throw SeedManagerError.uninitializedWallet
        }
        return value
    }
    
    func importPhrase(bip39 phrase: String) throws {
        guard keychain.get(Self.zECCWalletPhrase) == nil else { throw SeedManagerError.alreadyImported }
        keychain.set(phrase, forKey: Self.zECCWalletPhrase)
    }
    
    func exportPhrase() throws -> String {
        guard let seed = keychain.get(Self.zECCWalletPhrase) else { throw SeedManagerError.uninitializedWallet }
        return seed
    }
    
    func importLightWalletEndpoint(address: String) {
        guard keychain.get(Self.aRRRLightWalletEndpoint) == nil
        else {
            keychain.set(address, forKey: Self.aRRRLightWalletEndpoint)
            return
        }
        keychain.set(ZECCWalletEnvironment.defaultLightWalletEndpoint, forKey: Self.aRRRLightWalletEndpoint)
    }

    func exportLightWalletEndpoint() -> String {
        guard let address = keychain.get(Self.aRRRLightWalletEndpoint) else
        {
            return ZECCWalletEnvironment.defaultLightWalletEndpoint
        }
        return address
    }
    
    func setPinCode(pincoode: String) {
        guard keychain.get(Self.aRRRPincode) == nil
        else {
            keychain.set(pincoode, forKey: Self.aRRRPincode)
            return
        }
        keychain.set("", forKey: Self.aRRRPincode)
    }

    func getPinCode() -> String {
        guard let pincode = keychain.get(Self.aRRRPincode) else
        {
            return ""
        }
        return pincode
    }
    
    
    /**
     Use carefully: Deletes the seed phrase from the keychain
     */
    func nukePhrase() {
        keychain.delete(Self.zECCWalletPhrase)
    }
    /**
        Use carefully: Deletes the keys from the keychain
     */
    func nukeKeys() {
        keychain.delete(Self.zECCWalletKeys)
    }

    /**
       Use carefully: Deletes the seed from the keychain.
     */
    func nukeSeed() {
        keychain.delete(Self.zECCWalletSeedKey)
    }
    
    /**
     Use carefully: deletes the wallet birthday from the keychain
     */
    
    func nukeBirthday() {
        keychain.delete(Self.zECCWalletBirthday)
    }
    
    
    /**
    There's no fate but what we make for ourselves - Sarah Connor
    */
    func nukeWallet() {
        nukeKeys()
        nukeSeed()
        nukePhrase()
        nukeBirthday()
        
        // Fix: retrocompatibility with old wallets, previous to IVK Synchronizer updates 
        for key in keychain.allKeys {
            keychain.delete(key)
        }
    }
}
