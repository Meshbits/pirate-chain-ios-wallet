//
//  ExchangeSource.swift
//  ECC-Wallet
//
//  Created by Lokesh on 29/01/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import Foundation
import SwiftUI

struct ExchangeSource: View {

    @ObservedObject var marketsViewModel: MarketsViewModel = MarketsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var mCurrentSelectedSource = 2
    
//    var exchangesArray = [ "Kucoin Exchange", "Tradeogre Exchange" ]
//
    var body: some View {
        
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                List {
                    
                        Section(header: Text("Kucoin Exchange").font(.barlowRegular(size: 20)).foregroundColor(Color.zSettingsSectionHeader).background(Color.clear).cornerRadius(20)) {
                                                       
                            
                            HStack{
                                HStack{
                                    Text("ARRR-BTC").scaledFont(size: Device.isLarge ? 20 : 12)
                                }
                                Spacer()
                                Image(systemName: "checkmark").resizable().frame(width: 10, height: 10, alignment: .trailing).foregroundColor(mCurrentSelectedSource == 0 ? Color.arrrBarAccentColor : Color.textTitleColor)
                                    .padding(.trailing,10).opacity(mCurrentSelectedSource == 0 ? 1 : 0)
                                
                            }.background(Rectangle().fill(Color.init(red: 27.0/255.0, green: 28.0/255.0, blue: 29.0/255.0))).onTapGesture {
                                UserSettings.shared.indexOfSelectedExchange = 0
                                mCurrentSelectedSource = UserSettings.shared.indexOfSelectedExchange!
                            }
                            
                            HStack{
                                HStack{
                                    Text("ARRR-USDT").scaledFont(size: Device.isLarge ? 20 : 12)
                                }
                                Spacer()
                                
                                Image(systemName: "checkmark").resizable().frame(width: 10, height: 10, alignment: .trailing).foregroundColor(mCurrentSelectedSource == 1 ? Color.arrrBarAccentColor : Color.textTitleColor)
                                    .padding(.trailing,10).opacity(mCurrentSelectedSource == 1 ? 1 : 0)
                                
                            }.background(Rectangle().fill(Color.init(red: 27.0/255.0, green: 28.0/255.0, blue: 29.0/255.0))).onTapGesture {
                                UserSettings.shared.indexOfSelectedExchange = 1
                                mCurrentSelectedSource = UserSettings.shared.indexOfSelectedExchange!
                            }
                            
                         }
                        .modifier(ExchangeSourceHeaderStyle())
                    
                        Section(header: Text("Tradeogre Exchange").font(.barlowRegular(size: 20)).foregroundColor(Color.zSettingsSectionHeader).background(Color.clear).cornerRadius(20)) {
                            
                            
                            HStack{
                                HStack{
                                    Text("ARRR-BTC").scaledFont(size: Device.isLarge ? 20 : 12)
                                }
                                Spacer()
                                
                                Image(systemName: "checkmark").resizable().frame(width: 10, height: 10, alignment: .trailing).foregroundColor(mCurrentSelectedSource == 2 ? Color.arrrBarAccentColor : Color.textTitleColor)
                                    .padding(.trailing,10).opacity(mCurrentSelectedSource == 2 ? 1 : 0)
                                
                            }.background(Rectangle().fill(Color.init(red: 27.0/255.0, green: 28.0/255.0, blue: 29.0/255.0))).onTapGesture {
                                UserSettings.shared.indexOfSelectedExchange = 2
                                mCurrentSelectedSource = UserSettings.shared.indexOfSelectedExchange!
                            }
                            
                         }
                        .modifier(ExchangeSourceHeaderStyle())
                }
            }
            .navigationBarBackButtonHidden(true)
               .navigationTitle("Exchange Source".localized()).navigationBarTitleDisplayMode(.inline)
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
        .onAppear(){
              mCurrentSelectedSource = UserSettings.shared.indexOfSelectedExchange ?? 2
//            DispatchQueue.global().async {
//                marketsViewModel.getAllMarketsList()
//            }
        }
    }
    
    
}

struct ExchangeSourceHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 14, *) {
                AnyView(content.textCase(.none))
            } else {
                content
            }
        }
    }
}
