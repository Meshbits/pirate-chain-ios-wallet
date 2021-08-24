//
//  PirateChainPaymentURI.swift
//  PirateChainPaymentURI
//
//  Created by Sandro Machado on 12/07/16.
//  Copyright © 2016 Sandro. All rights reserved.
//

import Foundation

/// The Bitcoin Payment URI.
open class PirateChainPaymentURI: PirateChainPaymentURIProtocol {
    
    /// Closure to do the builder.
    public typealias buildPirateChainPaymentURIClosure = (PirateChainPaymentURI) -> Void
    
    fileprivate static let SCHEME = "arrr"
    fileprivate static let PARAMETER_AMOUNT = "amount"
    fileprivate static let PARAMETER_LABEL = "label"
    fileprivate static let PARAMETER_MESSAGE = "message"
    fileprivate static let PARAMETER_REQUIRED_PREFIX = "req-"

    fileprivate var allParameters: [String: Parameter]?

    open var isDeepLink: Bool?
    
    /// The address.
    open var address: String?
    
    /// The amount.
    open var amount: Double? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[PirateChainPaymentURI.PARAMETER_AMOUNT] = Parameter(value: String(newValue), required: false)
        }
        
        get {
            guard let parameters = self.allParameters, let amount = parameters[PirateChainPaymentURI.PARAMETER_AMOUNT]?.value else {
                return nil
            }
            
            return Double(amount)
        }
    }
    
    /// The label.
    open var label: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[PirateChainPaymentURI.PARAMETER_LABEL] = Parameter(value: newValue, required: false)
        }
        
        get {
            guard let parameters = self.allParameters, let label = parameters[PirateChainPaymentURI.PARAMETER_LABEL]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The message.
    open var message: String? {
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            self.allParameters?[PirateChainPaymentURI.PARAMETER_MESSAGE] = Parameter(value: newValue, required: false)
        }

        get {
            guard let parameters = self.allParameters, let label = parameters[PirateChainPaymentURI.PARAMETER_MESSAGE]?.value else {
                return nil
            }
            
            return label
        }
    }
    
    /// The parameters.
    open var parameters: [String: Parameter]? {
        set(newValue) {
            var newParameters: [String: Parameter] = [:]

            guard let allParameters = self.allParameters, let newValue = newValue else {
                return
            }
            
            for (key, value) in newValue {
                newParameters[key] = value
            }
            
            for (key, value) in allParameters {
                newParameters[key] = value
            }
            
            self.allParameters = newParameters
        }
        
        get {
            guard var parametersFiltered = self.allParameters else {
                return nil
            }
            
            parametersFiltered.removeValue(forKey: PirateChainPaymentURI.PARAMETER_AMOUNT)
            parametersFiltered.removeValue(forKey: PirateChainPaymentURI.PARAMETER_LABEL)
            parametersFiltered.removeValue(forKey: PirateChainPaymentURI.PARAMETER_MESSAGE)
            
            return parametersFiltered
        }
    }
    
    // The uri.
    open var uri: String? {
        get {
            var urlComponents = URLComponents()
            urlComponents.scheme = PirateChainPaymentURI.SCHEME
            urlComponents.host = self.address!;
            urlComponents.queryItems = []
            
            guard let allParameters = self.allParameters else {
                return urlComponents.string
            }
            
            for (key, value) in allParameters {
                if (value.required) {
                    urlComponents.queryItems?.append(URLQueryItem(name: "\(PirateChainPaymentURI.PARAMETER_REQUIRED_PREFIX)\(key)", value: value.value))
                    
                    continue
                }
                
                urlComponents.queryItems?.append(URLQueryItem(name: key, value: value.value))
            }
            
            if isDeepLink == true {
                return urlComponents.string
            }else{
                
                if let url = urlComponents.string {
                    return url.replacingOccurrences(of: "arrr://", with: "arrr:")
                }
                
                return nil
            }
        }
    }
    
    /**
      Constructor.
     
      - parameter build: The builder to generate a PirateChainPaymentURI.
    */
    public init(build: buildPirateChainPaymentURIClosure) {
        allParameters = [:]

        build(self)
    }
    
    /**
      Converts a String to a PirateChainPaymentURI.
     
      - parameter pirateChainPaymentURI: The string with the Bitcoin Payment URI.
     
      - returns: a PirateChainPaymentURI.
    */
    public static func parse(_ pirateChainPaymentURI: String?) -> PirateChainPaymentURI? {
        
        guard let pirateURI = pirateChainPaymentURI, !pirateURI.isEmpty else {
            return nil
        }
                
        let schemeRange = pirateURI.index(pirateURI.startIndex, offsetBy: 0)..<pirateURI.index(pirateURI.startIndex, offsetBy: SCHEME.count)
        let paramReqRange = pirateURI.index(pirateURI.startIndex, offsetBy: 0)..<pirateURI.index(pirateURI.startIndex, offsetBy: PARAMETER_REQUIRED_PREFIX.count)

        guard let _ = pirateURI.range(of: SCHEME, options: NSString.CompareOptions.caseInsensitive, range: schemeRange) else {
            return nil
        }
        
        if !pirateURI.starts(with: "arrr") {
            // Checking if arrr is there in the address
            return nil
        }
        
        let url:URL = URL(string: String(pirateURI))!
        
        var anAddress = ""
        
        // Use case for deep link
        if pirateURI.hasPrefix("arrr://"){
            guard let address = url.host else {
                return nil
            }
            anAddress = address
        }else if pirateURI.hasPrefix("arrr:"){
            // Use case for payment URI
            let urlComponents = URLComponents(string: String(pirateURI))
                    
            guard let address = urlComponents?.path, !address.isEmpty else {
               return nil
            }
            anAddress = address
        }else{
            return nil
        }
        

        let urlComponents = QueryParameters.init(url: url).queryItems
      
        return PirateChainPaymentURI(build: {
            $0.address = anAddress
            var newParameters: [String: Parameter] = [:]
            
            if urlComponents.count > 0 {
                for queryItem in urlComponents {
                    guard let value = queryItem.value else {
                        continue
                    }
                    
                    var required: Bool = true
                    
                    if (queryItem.name.count <= PARAMETER_REQUIRED_PREFIX.count || queryItem.name.range(of: PARAMETER_REQUIRED_PREFIX, options: NSString.CompareOptions.caseInsensitive, range: paramReqRange) == nil) {
                        required = false
                    }
                    
                    newParameters[queryItem.name.replacingOccurrences(of: PARAMETER_REQUIRED_PREFIX, with: "")] = Parameter(value: value, required: required)
                }
            }
            
            $0.parameters = newParameters
        })
    }

}

extension URL {
    var getQueryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}
