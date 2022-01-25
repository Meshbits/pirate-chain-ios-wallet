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
