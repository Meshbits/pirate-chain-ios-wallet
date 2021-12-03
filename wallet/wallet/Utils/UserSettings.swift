//
//  UserSettings.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 1/29/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation


class UserSettings {
    
    static let shared = UserSettings()
    
    private init() {}
    struct Keys {
        static let lastUsedAddress = "lastUsedAddress"
        static let everShielded = "everShielded"
        static let rescanPendingFix = "rescanPendingFix"
        static let lastFeedbackDisplayedOnDate = "lastFeedbackDisplayedOnDate"
        static let aPasscode = "aPasscode"
        static let aBiometricInAppStatus = "aBiometricInAppStatus"
        static let aBiometricEnabled = "aBiometricEnabled"
        static let aLanguageSelectionIndex = "aLanguageSelectionIndex"
        static let isAutoConfigurationOn = "isAutoConfigurationOn"
        static let lastUpdatedTime = "lastSavedTime"
    }
    
    
    var lastUpdatedTime: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.lastUpdatedTime)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastUpdatedTime)
        }
    }
        
    var aPasscode: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.aPasscode)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.aPasscode)
//            SeedManager.default.updatePasswordForPinCode()
        }
    }
    
    var lastUsedAddress: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.lastUsedAddress)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastUsedAddress)
        }
    }
    
    var userEverShielded: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.everShielded)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.everShielded)
        }
    }
    
    var didRescanPendingFix: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.rescanPendingFix)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey:Keys.rescanPendingFix)
        }
    }
    
    var lastFeedbackDisplayedOnDate: Date? {
        get {
            guard let timeInterval = UserDefaults.standard.value(forKey: Keys.lastFeedbackDisplayedOnDate) as? TimeInterval else {
                return nil
            }
            
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        set {
            UserDefaults.standard.setValue(newValue?.timeIntervalSinceReferenceDate, forKey: Keys.lastFeedbackDisplayedOnDate)
        }
    }
    
    var biometricInAppStatus: Bool  {
         get {
             UserDefaults.standard.bool(forKey: Keys.aBiometricInAppStatus)
         }
         set {
             UserDefaults.standard.setValue(newValue, forKey: Keys.aBiometricInAppStatus)
         }
     }
     
     var isBiometricDisabled: Bool  {
         get {
             UserDefaults.standard.bool(forKey: Keys.aBiometricEnabled)
         }
         set {
             UserDefaults.standard.setValue(newValue, forKey: Keys.aBiometricEnabled)
         }
     }
    
    var languageSelectionIndex: Int  {
        get {
            UserDefaults.standard.integer(forKey: Keys.aLanguageSelectionIndex)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.aLanguageSelectionIndex)
        }
    }
    
    
    var isAutoConfigurationOn: Bool  {
        get {
            UserDefaults.standard.bool(forKey: Keys.isAutoConfigurationOn)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isAutoConfigurationOn)
        }
    }
    
    
    func removeAllSettings() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
