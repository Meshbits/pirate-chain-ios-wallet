//
//  PirateChainPaymentURIProtocol.swift
//  PirateChainPaymentURI
//
//  Created by Lokesh Sehgal on 15/06/21.
//

import Foundation

protocol PirateChainPaymentURIProtocol {
    
    var address: String? { get }
    
    var amount: Double? { get }
    
    var label: String? { get }
    
    var message: String? { get }
    
    var parameters: [String: Parameter]? { get }
    
}
