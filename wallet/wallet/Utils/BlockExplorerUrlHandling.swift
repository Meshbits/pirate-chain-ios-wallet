//
//  BlockExplorerUrlHandling.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 8/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation
import PirateLightClientKit
class UrlHandler {
    
    static func blockExplorerURL(for txId: String) -> URL? {
        PirateSDK.isMainnet ? blockExplorerURLMainnet(for: txId) : blockExplorerURLTestnet(for: txId)
    }
    
    // blockchair does not support testnet zcash
    static func blockExplorerURLTestnet(for txId: String) -> URL? {
        var urlComponents = URLComponents()

        urlComponents.host = "explorer.testnet.z.cash"
        urlComponents.scheme = "https"
        urlComponents.path = "/tx"
        
        return urlComponents.url?.appendingPathComponent(txId)
    }
    
    static func blockExplorerURLMainnet(for txId: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.host = "explorer.pirate.black"
        urlComponents.scheme = "https"
        urlComponents.path = "/tx"
        
        return urlComponents.url?.appendingPathComponent(txId)
    }
}
