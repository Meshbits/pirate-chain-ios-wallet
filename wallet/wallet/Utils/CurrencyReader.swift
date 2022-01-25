//
//  CurrencyReader.swift
//  ECC-Wallet
//
//  Created by Lokesh on 25/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation
class CurrencyReader: ObservableObject  {
    @Published var currencies = [CurrencyModel]()
            
    init(){
        loadData()
    }
    
    func loadData()  {
        guard let url = Bundle.main.url(forResource: "currency", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        let data = try? Data(contentsOf: url)
        let currencies = try? JSONDecoder().decode([CurrencyModel].self, from: data!)
        self.currencies = currencies!
        
    }
     
}
