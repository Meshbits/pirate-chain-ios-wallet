//
//  PirateSDK.swift
//  PirateLightClientKit
//
//  Created by Francisco Gindre on 7/22/21.
//

import Foundation
public protocol PirateNetwork {
    var networkType: NetworkType { get }
    var constants: NetworkConstants.Type { get }
}

public enum NetworkType {
    case mainnet
    case testnet

    var networkId: UInt32 {
        switch self {
        case .mainnet:  return 1
        case .testnet:  return 0
        }
    }
}

extension NetworkType {
    static func forChainName(_ chainame: String) -> NetworkType? {
        switch chainame {
        case "test":    return .testnet
        case "main":    return .mainnet
        default:        return nil
        }
    }

    static func forNetworkId(_ id: UInt32) -> NetworkType? {
        switch id {
        case 1: return .mainnet
        case 0: return .testnet
        default: return nil
        }
    }
}

extension NetworkType {
    public var chainName: String {
        switch self {
        case .mainnet:
            return "main"
        case .testnet:
            return "test"
        }
    }
}

public enum PirateNetworkBuilder {
    public static func network(for networkType: NetworkType) -> PirateNetwork {
        switch networkType {
        case .mainnet:  return ZcashMainnet()
        case .testnet:  return ZcashTestnet()
        }
    }
}

class ZcashTestnet: PirateNetwork {
    let networkType: NetworkType = .testnet
    let constants: NetworkConstants.Type = PirateSDKTestnetConstants.self
}

class ZcashMainnet: PirateNetwork {
    let networkType: NetworkType = .mainnet
    let constants: NetworkConstants.Type = PirateSDKMainnetConstants.self
}

/**
Constants of PirateLightClientKit. this constants don't
*/
public enum PirateSDK {
    /// The number of zatoshi that equal 1 ZEC.
    public static let zatoshiPerZEC: BlockHeight = 100_000_000

    /// The theoretical maximum number of blocks in a reorg, due to other bottlenecks in the protocol design.
    public static let maxReorgSize = 100

    /// The amount of blocks ahead of the current height where new transactions are set to expire. This value is controlled
    /// by the rust backend but it is helpful to know what it is set to and should be kept in sync.
    public static let expiryOffset = 20

    // MARK: Defaults

    /// Default size of batches of blocks to request from the compact block service. Which was used both for scanning and downloading.
    /// consider basing your code assumptions on `DefaultDownloadBatch` and `DefaultScanningBatch` instead.
    @available(*, deprecated, message: "this value is being deprecated in favor of `DefaultDownloadBatch` and `DefaultScanningBatch`")
    public static let DefaultBatchSize = 1000

    /// Default batch size for downloading blocks for the compact block processor. Be careful with this number. This amount of blocks is held in
    /// memory at some point of the sync process.
    /// This values can't be smaller than `DefaultScanningBatch`. Otherwise bad things will happen.
    public static let DefaultDownloadBatch = 1000

    /// Default batch size for scanning blocks for the compact block processor
    public static let DefaultScanningBatch = 100

    /// Default amount of time, in in seconds, to poll for new blocks. Typically, this should be about half the average
    /// block time.
    public static let defaultPollInterval: TimeInterval = 20

    /// Default attempts at retrying.
    public static let defaultRetries: Int = 5

    /// The default maximum amount of time to wait during retry backoff intervals. Failed loops will never wait longer than
    /// this before retrying.
    public static let defaultMaxBackOffInterval: TimeInterval = 600

    /// Default number of blocks to rewind when a chain reorg is detected. This should be large enough to recover from the
    /// reorg but smaller than the theoretical max reorg size of 100.
    public static let defaultRewindDistance: Int = 10

    /// The number of blocks to allow before considering our data to be stale. This usually helps with what to do when
    /// returning from the background and is exposed via the Synchronizer's isStale function.
    public static let defaultStaleTolerance: Int = 10

    /// Default Name for LibRustZcash data.db
    public static let defaultDataDbName = "pirate_data.db"

    /// Default Name for Compact Block file system based db
    public static let defaultFsCacheName = "fs_cache_pirate"

    /// Default Name for Compact Block caches db
    public static let defaultCacheDbName = "pirate_caches.db"

    /// The Url that is used by default in zcashd.
    /// We'll want to make this externally configurable, rather than baking it into the SDK but
    /// this will do for now, since we're using a cloudfront URL that already redirects.
    public static let cloudParameterURL = "https://z.cash/downloads/"

    /// File name for the sapling spend params
    public static let spendParamFilename = "sapling-spend.params"
    // swiftlint:disable:next force_unwrapping
    public static let spendParamFileURL = URL(string: cloudParameterURL)!.appendingPathComponent(spendParamFilename)

    /// File name for the sapling output params
    public static let outputParamFilename = "sapling-output.params"
    // swiftlint:disable:next force_unwrapping
    public static let outputParamFileURL = URL(string: cloudParameterURL)!.appendingPathComponent(outputParamFilename)
}

public protocol NetworkConstants {
    /// The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
    /// prior to this height, at all.
    static var saplingActivationHeight: BlockHeight { get }

    /// Default Name for LibRustZcash data.db
    static var defaultDataDbName: String { get }

    static var defaultFsBlockDbRootName: String { get }

    /// Default Name for Compact Block caches db
    @available(*, deprecated, message: "use this name to clean up the sqlite compact block database")
    static var defaultCacheDbName: String { get }

    /// Default prefix for db filenames
    static var defaultDbNamePrefix: String { get }

    /// fixed height where the SDK considers that the ZIP-321 was deployed. This is a workaround
    /// for librustzcash not figuring out the tx fee from the tx itself.
    static var feeChangeHeight: BlockHeight { get }

    /// Returns the default fee according to the blockheight. see [ZIP-313](https://zips.z.cash/zip-0313)
    static func defaultFee(for height: BlockHeight) -> Zatoshi
}

public extension NetworkConstants {
    static func defaultFee(for height: BlockHeight = BlockHeight.max) -> Zatoshi {
        //guard height >= feeChangeHeight else { return Zatoshi(10_000) }

        return Zatoshi(10_000)
    }
}

public enum PirateSDKMainnetConstants: NetworkConstants {
    /// The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
    /// prior to this height, at all.
    public static let saplingActivationHeight: BlockHeight = 152_855

    /// Default Name for LibRustZcash data.db
    public static let defaultDataDbName = "pirate_data.db"

    public static let defaultFsBlockDbRootName = "fs_cache_pirate"

    /// Default Name for Compact Block caches db
    public static let defaultCacheDbName = "pirate_caches.db"

    public static let defaultDbNamePrefix = "PirateSdk_mainnet_"

    public static let feeChangeHeight: BlockHeight = 1_077_550
}

public enum PirateSDKTestnetConstants: NetworkConstants {
    /// The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
    /// prior to this height, at all.
    public static let saplingActivationHeight: BlockHeight = 280_000

    /// Default Name for LibRustZcash data.db
    public static let defaultDataDbName = "pirate_data.db"

    /// Default Name for Compact Block caches db
    public static let defaultCacheDbName = "pirate_caches.db"

    public static let defaultFsBlockDbRootName = "fs_cache_pirate"

    public static let defaultDbNamePrefix = "PirateSdk_testnet_"

    /// Estimated height where wallets are supposed to change the fee
    public static let feeChangeHeight: BlockHeight = 1_028_500
}