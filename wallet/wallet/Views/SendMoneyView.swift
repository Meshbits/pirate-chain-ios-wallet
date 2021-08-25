//
//  SendMoneyView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 25/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct SendMoneyView: View {
    
    @State var isSendTapped = false
    @State var aMemoText: String = ""
    @State var sendArrrValue =  "0"
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            ARRRBackground()
            VStack{
                
                Spacer()
                Spacer()
                HStack{
                    Text("Memo").font(.barlowRegular(size: 22)).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:$aMemoText).frame(height:60)
                
                Text(self.sendArrrValue)
                    .foregroundColor(.gray)
                    .font(.barlowRegular(size: Device.isLarge ? 40 : 30))
                    .frame(height:40)
                    .padding(.leading,10)
                    .padding(.trailing,10)
                    .modifier(BackgroundPlaceholderModifier())
            
                HStack{
                    Spacer()
                    Text("Processing fee: " + "\(ZcashSDK.defaultFee().asHumanReadableZecBalance().toZecAmount())" + " ARRR").font(.barlowRegular(size: 14)).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle)
                    Spacer()
                }
                              
                KeyPadARRR(value: $sendArrrValue)
                    .frame(alignment: .center)
                    .padding(.horizontal, 10)
                
                BlueButtonView(aTitle: "Send").onTapGesture {
                    isSendTapped = true
                }
                
            }.zcashNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                     Text("Send Money")
                         .font(.barlowRegular(size: 26)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center)
                        .padding(.top,20)
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     presentationMode.wrappedValue.dismiss()
                     }).frame(width: 30, height: 30)
                 .padding(.top,20)
             })
        }
    }
}

//struct SendMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendMoneyView()
//    }
//}
