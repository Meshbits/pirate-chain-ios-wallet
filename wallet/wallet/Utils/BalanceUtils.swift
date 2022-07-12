//
//  BalanceUtils.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import ZcashLightClientKit

extension Int64 {
    func asHumanReadableZecBalance() -> Double {
        var decimal = Decimal(self) / Decimal(ZcashSDK.zatoshiPerZEC)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, 6, .bankers)
        return (rounded as NSDecimalNumber).doubleValue
    }
}

extension Double {
    
    func toZatoshi() -> Int64 {
        var decimal = Decimal(self) * Decimal(ZcashSDK.zatoshiPerZEC)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, 6, .bankers)
        return (rounded as NSDecimalNumber).int64Value
    }
    
    func toZecAmount() -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Zatoshi {

    static var defaultNetworkFee: Zatoshi = ZCASH_NETWORK.constants.defaultFee()

    // Absolute value + network fee
    func addingZcashNetworkFee(_ fee: Zatoshi = Self.defaultNetworkFee) -> Zatoshi {
        Zatoshi(abs(self.amount)) + fee
    }
}

extension NumberFormatter {
    static var zecAmountFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 8
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 1
        return fmt
        
    }
    
    static var zeroBalanceFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 0
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 1
        return fmt
        
    }
}

