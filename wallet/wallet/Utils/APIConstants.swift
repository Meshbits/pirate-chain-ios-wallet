//
//  APIConstants.swift
//  ECC-Wallet
//
//  Created by Lokesh on 29/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://api.piratewallet.io/v1/"
    static let marketAPI = "price/markets"
    static let selectedCurrenciesAPI = "price/%@/%@?symbols=%@"
}

