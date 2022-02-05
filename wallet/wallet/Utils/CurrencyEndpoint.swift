//
//  CurrencyEndpoint.swift
//  ECC-Wallet
//
//  Created by Lokesh on 29/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation


enum CurrencyEndpoint {
    case marketList
    case selectedCurrenciesAPI
}

extension CurrencyEndpoint : RequestBuilder {
    var urlRequest: URLRequest {
        switch self {
            
        case .marketList:
            
            guard let url = URL(string: String.init(format: "%@%@", APIConstants.baseURL,APIConstants.marketAPI)) else {
                    preconditionFailure("Invalid URL")
                }
                let request = URLRequest(url: url)
                return request
            
        case .selectedCurrenciesAPI:
        guard let url = URL(string: String.init(format: "%@%@", APIConstants.baseURL,APIConstants.selectedCurrenciesAPI)) else {
                preconditionFailure("Invalid URL")
            }
            let request = URLRequest(url: url)
            return request
        }
    }
}
