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
    }
    
    
    var aPasscode: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.aPasscode)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.aPasscode)
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
    
}
