//
//  String+Zcash.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension String {
    /**
     network aware ZEC string. When on mainnet it will read ZEC and TAZ when on Testnet
     */
    static var ZEC: String {
        switch ZCASH_NETWORK.networkType {
        case .mainnet:
            return "ZEC"
        case .testnet:
            return "TAZ"
        }
    }
    
    var isValidShieldedAddress: Bool {
        DerivationTool(networkType: ZCASH_NETWORK.networkType).isValidSaplingAddress(self)
    }
    
    var isValidTransparentAddress: Bool {
        DerivationTool(networkType: ZCASH_NETWORK.networkType).isValidTransparentAddress(self)
    }
    
    var isValidAddress: Bool {
        guard (try? Recipient(self, network: ZCASH_NETWORK.networkType)) != nil else {
            return false
        }

        return true
    }
    
    /**
     This only shows an abbreviated and redacted version of the Z addr for UI purposes only
     */
    var shortZaddress: String? {
        guard isValidAddress else { return nil }
        return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 8)])
            + "..."
            + String(self[self.index(self.endIndex, offsetBy: -8) ..< self.endIndex])
    }

    /// This only shows an abbreviated and redacted version of the an addr for UI purposes only
    var shortAddress: String {
        String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 8)])
            + "..."
            + String(self[self.index(self.endIndex, offsetBy: -8) ..< self.endIndex])
    }

}
