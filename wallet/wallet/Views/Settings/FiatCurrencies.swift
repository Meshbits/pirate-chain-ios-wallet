//
//  FiatCurrencies.swift
//  ECC-Wallet
//
//  Created by Lokesh on 25/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class FiatCurrenciesModel: ObservableObject {
   
    @Published var currencyList = CurrencyReader()
    
    @Published var mSelectedCurrencies: [CurrencyModel] = []
        
     func isSelectedCurrency(currency: CurrencyModel) -> Bool{
         
         return mSelectedCurrencies.contains(currency)
         
     }
    
    func updateSelectedCurrencies(currency: CurrencyModel){
        if self.isSelectedCurrency(currency: currency) {
            if let index = self.mSelectedCurrencies.firstIndex(of: currency) {
                self.mSelectedCurrencies.remove(at: index)
            }
        }else{
            self.mSelectedCurrencies.append(currency)
        }
        
    }
}

struct FiatCurrencies: View {

    @StateObject var viewModel: FiatCurrenciesModel = FiatCurrenciesModel()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                                
                List(viewModel.currencyList.currencies){ currency in
                       
                       VStack(alignment: .leading) {
                           
                           VStack {
                               HStack{
                                   HStack{
                                       Text(currency.currency)
                                           .font(.caption)
                                       Text("("+currency.abbreviation+")")
                                           .font(.caption)
                                   }                                   
                                   Spacer()
                                   Image(systemName: self.viewModel.isSelectedCurrency(currency: currency) ? "checkmark.square.fill" : "square").resizable().frame(width: 12, height: 12, alignment: .trailing).foregroundColor(self.viewModel.isSelectedCurrency(currency: currency) ? Color.arrrBarAccentColor : Color.zDudeItsAlmostWhite)
                                       .padding(.trailing,10)
                                   
                               }.background(Rectangle().fill(Color.init(red: 27.0/255.0, green: 28.0/255.0, blue: 29.0/255.0)))
                           }.frame(height: Device.isLarge ?  60 : 40)
                               .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                           .onTapGesture {
                               self.viewModel.updateSelectedCurrencies(currency: currency)
                           }
                         
                       }
                   }  .modifier(BackgroundPlaceholderModifierRescanOptions()).padding()
            }
        } .navigationBarBackButtonHidden(true)
            .navigationTitle("Fiat Currencies".localized()).navigationBarTitleDisplayMode(.inline)
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
