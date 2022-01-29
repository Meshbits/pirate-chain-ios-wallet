//
//  CurrencyService.swift
//  ECC-Wallet
//
//  Created by Lokesh on 28/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine

protocol CurrencyService {
    var apiSession: PirateAPIService {get}
    
    func getAllMarketsList() -> AnyPublisher<MarketListAPIResponse, CurrencyAPIError>
}

extension CurrencyService {
    
    func getAllMarketsList() -> AnyPublisher<MarketListAPIResponse, CurrencyAPIError> {
        return apiSession.request(with: CurrencyEndpoint.marketList)
            .eraseToAnyPublisher()
    }
}
