//
//  Future+async.swift
//  ECC-Wallet
//
//  Created by John Sundell on 10/5/22.
//  source: https://www.swiftbysundell.com/articles/creating-combine-compatible-versions-of-async-await-apis/
//

import Foundation
import Combine
extension Future where Failure == Error {
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
