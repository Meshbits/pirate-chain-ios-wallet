//
//  URL+Zcash.swift
//  wallet
//
//  Created by Francisco Gindre on 1/24/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit


extension URL {
    
    static func documentsDirectory() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    static func cacheDbURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(ZCASH_NETWORK.constants.defaultDbNamePrefix+ZcashSDK.defaultCacheDbName, isDirectory: false)
    }

    static func dataDbURL() throws -> URL {
        try documentsDirectory().appendingPathComponent(ZCASH_NETWORK.constants.defaultDbNamePrefix+ZcashSDK.defaultDataDbName, isDirectory: false)
    }

    static func pendingDbURL() throws -> URL {
        // FIX: this is using the wrong DB name which is not that serious because the Pending DB is purged
        // now and then and it's information is discarded when the transaction is found on chain
        // see https://github.com/zcash/zcash-ios-wallet/issues/309
        try documentsDirectory().appendingPathComponent(ZCASH_NETWORK.constants.defaultCacheDbName+ZcashSDK.defaultPendingDbName)
    }

    static func spendParamsURL() throws -> URL {
        try documentsDirectory().appendingPathComponent("sapling-spend.params")
    }

    static func outputParamsURL() throws -> URL {
        try documentsDirectory().appendingPathComponent("sapling-output.params")
    }
    
    static func bundledSpendParamsURL() -> URL? {
        Bundle.main.url(forResource: "sapling-spend", withExtension: ".params")
    }

    static func bundledOutputParamsURL() -> URL? {
        Bundle.main.url(forResource: "sapling-output", withExtension: ".params")
    }
}
