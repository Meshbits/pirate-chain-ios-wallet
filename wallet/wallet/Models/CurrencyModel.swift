//
//  CurrencyModel.swift
//  ECC-Wallet
//
//  Created by Lokesh on 25/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation

struct CurrencyModel: Codable, Identifiable, Equatable {
    enum CodingKeys: CodingKey {
        case currency
        case abbreviation
    }
    var id = UUID()
    var currency: String
    var abbreviation: String
}


// Model used to pull markets
struct MarketListAPIResponse: Codable, Equatable {
    var binance, fixer, kucoin, safetrade, tradeogre : [String]
    enum CodingKeys: CodingKey {
        case tradeogre
        case binance
        case fixer
        case kucoin
        case safetrade
    }
}

struct SelectedCurrencyAPIResponse: Codable, Equatable {
    var timestamp : Int
    var base : String
    var market : String
    var rates : [String:String]
    
    enum CodingKeys: CodingKey {
        case timestamp
        case base
        case market
        case rates
    }
}
