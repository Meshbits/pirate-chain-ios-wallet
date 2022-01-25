//
//  FiatCurrencies.swift
//  ECC-Wallet
//
//  Created by Lokesh on 25/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct FiatCurrencies: View {
    @ObservedObject var currencyList = CurrencyReader()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                                
                   List(currencyList.currencies){ currency in
                       
                       VStack(alignment: .leading) {
                                           
                           HStack{
                               Text(currency.currency)
                                   .font(.caption)
                                   
                               Spacer()
                               
                               Text(currency.abbreviation)
                                   .font(.caption)
                           }
                       }
                   }  .modifier(BackgroundPlaceholderModifierRescanOptions()).padding()
            }
        } .navigationBarBackButtonHidden(true)
            .navigationTitle("Fiat Currency".localized()).navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:  Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("backicon").resizable().frame(width: 50, height: 50)
                    }
                }
            })
        
        
        
   }
}

struct FiatCurrencies_Previews: PreviewProvider {
    static var previews: some View {
        FiatCurrencies()
    }
}
