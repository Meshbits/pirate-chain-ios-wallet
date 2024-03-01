//
//  ResourceProvider.swift
//  PirateLightClientKit
//
//  Created by Francisco Gindre on 19/09/2019.
//  Copyright © 2019 Electric Coin Company. All rights reserved.
//

import Foundation

public enum ResourceProviderError: Error {
    case unavailableResource
}
public protocol ResourceProvider {
    var dataDbURL: URL { get }
    var fsCacheURL: URL { get }
}
/**
Convenience provider for a data db and cache db resources.
*/
public struct DefaultResourceProvider: ResourceProvider {
    let network: PirateNetwork

    public var dataDbURL: URL {
        let constants = network.constants
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return url.appendingPathComponent(constants.defaultDataDbName)
        } catch {
            return URL(fileURLWithPath: "file://\(constants.defaultDataDbName)")
        }
    }

    public var fsCacheURL: URL {
        let constants = network.constants
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return path.appendingPathComponent(constants.defaultFsBlockDbRootName)
        } catch {
            return URL(fileURLWithPath: "file://\(constants.defaultFsBlockDbRootName)")
        }
    }

    public var spendParamsURL: URL {
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return path.appendingPathComponent(PirateSDK.spendParamFilename)
        } catch {
            return URL(fileURLWithPath: "file://\(PirateSDK.spendParamFilename)")
        }
    }

    public var outputParamsURL: URL {
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return path.appendingPathComponent(PirateSDK.outputParamFilename)
        } catch {
            return URL(fileURLWithPath: "file://\(PirateSDK.outputParamFilename)")
        }
    }

    init(network: PirateNetwork) {
        self.network = network
    }
}
