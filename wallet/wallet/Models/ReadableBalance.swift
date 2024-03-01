//
//  ReadableBalance.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 4/26/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation
import PirateLightClientKit
struct ReadableBalance {
    var verified: Double
    var total: Double
}

extension ReadableBalance {
    init(walletBalance: WalletBalance) {
        self.init(verified: walletBalance.verified.amount.asHumanReadableZecBalance(),
                        total: walletBalance.total.amount.asHumanReadableZecBalance())
    }
    
    static var zero: ReadableBalance {
        ReadableBalance(verified: 0, total: 0)
    }
    
    var unconfirmedFunds: Double {
        total - verified
    }
}
