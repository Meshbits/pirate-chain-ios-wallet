//
//  SeedManagement.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//
import Foundation
import PirateLightClientKit
import SecureDefaults
final class SeedManager {
    
    enum SeedManagerError: Error {
        case alreadyImported
        case uninitializedWallet
    }
    static let mDefaultHeight = 1390000
    static var `default`: SeedManager = SeedManager()
    private static let aRRRWalletBirthday = "aRRRWalletBirthday"
    private static let aRRRWalletPhrase = "aRRRWalletPhrase"
    private static let aRRRLightWalletEndpoint = "aRRRLightWalletEndpoint"
    private static let aRRRLightWalletPort = "aRRRLightWalletPort"
    
    private let secureDefaults = SecureDefaults.shared
    private let userDefaults = UserDefaults.standard
    private var mTempRecoveryPhrase:String?
    
    func importBirthday(_ height: BlockHeight) throws {
        guard userDefaults.string(forKey: Self.aRRRWalletBirthday) == nil else {
            throw SeedManagerError.alreadyImported
        }
        
        if height == ZCASH_NETWORK.constants.SAPLING_ACTIVATION_HEIGHT {
            // Setting it to a default height to 1390000 instead of 152_855 - too small to deal with
            userDefaults.set(String(SeedManager.mDefaultHeight), forKey: Self.aRRRWalletBirthday)
        }else{
            userDefaults.set(String(height), forKey: Self.aRRRWalletBirthday)
        }
        
        
        userDefaults.synchronize()
    }
    
    func importNewBirthdayOnRescan(_ height: BlockHeight) throws {
       
        if height == ZCASH_NETWORK.constants.SAPLING_ACTIVATION_HEIGHT {
            // Setting it to a default height to 1390000 instead of 152_855 - too small to deal with
            userDefaults.set(String(SeedManager.mDefaultHeight), forKey: Self.aRRRWalletBirthday)
        }else{
            userDefaults.set(String(height), forKey: Self.aRRRWalletBirthday)
        }
        
        
        userDefaults.synchronize()
    }
    
    func exportBirthday() throws -> BlockHeight {
        guard let birthday = userDefaults.string(forKey: Self.aRRRWalletBirthday),
              let value = BlockHeight(birthday) else {
                  throw SeedManagerError.uninitializedWallet
              }
        return value
    }
    
    func importPhrase(bip39 phrase: String) throws {
//        printLog(message: "import phrase initiated")
        guard secureDefaults.string(forKey: Self.aRRRWalletPhrase) == nil else {
            throw SeedManagerError.alreadyImported
        }
//        printLog(message: "checked if already exists = no, then proceed")
        secureDefaults.set(phrase, forKey: Self.aRRRWalletPhrase)
        secureDefaults.synchronize()
//        printLog(message: "import finished")
    }
    
    func exportPhrase() throws -> String {
//        printLog(message: "Requested")
        if let seedphrase = mTempRecoveryPhrase {
//            printLog(message: "Found Locally")
            return seedphrase
        }
        
        guard let phrase = secureDefaults.string(forKey: Self.aRRRWalletPhrase) else { throw SeedManagerError.uninitializedWallet }
//        printLog(message: "Found in secure defaults")
        mTempRecoveryPhrase = phrase
        
        return phrase
    }
        
    func importLightWalletEndpoint(address: String) {
        guard userDefaults.string(forKey: Self.aRRRLightWalletEndpoint) == nil
        else {
            userDefaults.set(address, forKey: Self.aRRRLightWalletEndpoint)
            return
        }
        userDefaults.set(ZECCWalletEnvironment.defaultLightWalletEndpoint, forKey: Self.aRRRLightWalletEndpoint)
    }

    func exportLightWalletEndpoint() -> String {
        guard let address = userDefaults.string(forKey: Self.aRRRLightWalletEndpoint) else
        {
            return ZECCWalletEnvironment.defaultLightWalletEndpoint
        }
        return address
    }
    
    func importLightWalletPort(port: Int) {
        guard userDefaults.string(forKey: Self.aRRRLightWalletPort) == nil
        else {
            userDefaults.set(String.init(format: "%d", port), forKey: Self.aRRRLightWalletPort)
            return
        }
        userDefaults.set(String.init(format: "%d", ZECCWalletEnvironment.defaultLightWalletPort), forKey: Self.aRRRLightWalletPort)
    }

    func exportLightWalletPort() -> Int {
        guard let port = userDefaults.string(forKey: Self.aRRRLightWalletPort) else
        {
            return ZECCWalletEnvironment.defaultLightWalletPort
        }
        return Int(port) ?? ZECCWalletEnvironment.defaultLightWalletPort
    }
        
    /**
     Use carefully: Deletes the seed phrase from the Secure Defaults
     */
    func nukePhrase() {
        mTempRecoveryPhrase = nil
        secureDefaults.removeObject(forKey: Self.aRRRWalletPhrase)
        secureDefaults.synchronize()
    }
    
    func nukeAll(){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    /**
     Use carefully: deletes the wallet birthday from the Secure Defaults
     */
    
    func nukeBirthday() {
        userDefaults.removeObject(forKey: Self.aRRRWalletBirthday)
    }
    
    /**
     Use carefully: deletes the wallet port from the Secure Defaults
     */
    
    func nukePort() {
        userDefaults.removeObject(forKey: Self.aRRRLightWalletPort)
    }
    
    /**
     Use carefully: deletes the wallet endpoint from the Secure Defaults
     */
    
    func nukeEndpoint() {
        userDefaults.removeObject(forKey: Self.aRRRLightWalletEndpoint)
    }
    
    /**
    There's no fate but what we make for ourselves - Sarah Connor
    */
    func nukeWallet() {
        nukeAll()
        nukePhrase()
        nukeBirthday()
        nukePort()
        nukeEndpoint()
        UserSettings.shared.removeAllSettings()
    }
    
    var keysPresent: Bool {
        do {
            _ = try self.exportPhrase()
            _ = try self.exportBirthday()
        } catch SeedManagerError.uninitializedWallet {
            return false
        } catch {
            tracker.track(.error(severity: .critical), properties: [
                            ErrorSeverity.messageKey : "attempted to find if keys were present but failed",
                            ErrorSeverity.underlyingError : error.localizedDescription])
            logger.error("attempted to find if keys were present but failed: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    func updatePasswordForPinCode(){
//        if secureDefaults.isKeyCreated {
//            if let seedphrase = mTempRecoveryPhrase {
//                if let aPasscode = UserSettings.shared.aPasscode, !aPasscode.isEmpty {
//                    printLog(message: "Started resetting")
//                    secureDefaults.removeObject(forKey: Self.aRRRWalletPhrase)
//                    secureDefaults.synchronize()
//                    printLog(message: "Deleted")
//                    secureDefaults.password = aPasscode
//                    secureDefaults.synchronize()
//                    printLog(message: "DELETED SUCCESS")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.secureDefaults.set(seedphrase, forKey: Self.aRRRWalletPhrase)
//                        self.secureDefaults.synchronize()
//                        printLog(message: "Synch")
//                    }
//                }
//            }
//        }
    }
    
    /**
        For logging purpose - testing with timestamp
     */
    func printLog(message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:ss.SSSS a"
        let timestamp = formatter.string(from: Date())
        let vMess = "\(timestamp) ------ \(message)"
        print(vMess)
    }

}
