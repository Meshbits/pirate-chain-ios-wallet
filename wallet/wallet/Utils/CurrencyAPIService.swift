//
//  CurrencyAPIService.swift
//  ECC-Wallet
//
//  Created by Lokesh on 28/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine

protocol CurrencyAPIService{
    func request<T: Decodable>(with builder: RequestBuilder) -> AnyPublisher<T, CurrencyAPIError>
}

protocol RequestBuilder {
    var urlRequest: URLRequest {get}
}

enum CurrencyAPIError: Error {
    case decodingError
    case httpError(Int)
    case unknown
}
