//
//  PirateAPISession.swift
//  ECC-Wallet
//
//  Created by Lokesh on 28/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation
import Combine

struct PirateAPISession: PirateAPIService {
    func request<T>(with builder: RequestBuilder) -> AnyPublisher<T, CurrencyAPIError> where T: Decodable {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared
            .dataTaskPublisher(for: builder.urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<T, CurrencyAPIError> in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                    return Just(data)
                        .decode(type: T.self, decoder: decoder)
                        .mapError {_ in .decodingError}
                        .eraseToAnyPublisher()
                    } else {
                        return Fail(error: CurrencyAPIError.httpError(response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: CurrencyAPIError.unknown)
                        .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
