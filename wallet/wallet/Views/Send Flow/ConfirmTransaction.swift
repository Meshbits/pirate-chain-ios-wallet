//
//  ConfirmTransaction.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 21/10/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ConfirmTransaction: View {
    @EnvironmentObject var flow: SendFlowEnvironment
    @Environment(\.presentationMode) var presentationMode
    var body: some View {

            ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack {

            List {
                
                
                ConfirmTableSectionHeaderView(aTitle:"From: ".localized())
                    HStack{
                        Text(ZECCWalletEnvironment.shared.synchronizer.unifiedAddress.zAddress)
                            .foregroundColor(.white)
                            .scaledFont(size: 15)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .frame(minHeight: 50)
                
                    ConfirmTableSectionHeaderView(aTitle:"To: ".localized())
                       
                    HStack{
                        Text("\(flow.address)").multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .scaledFont(size: 15)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .frame(minHeight: 50)
                    
                ConfirmTableSectionHeaderView(aTitle:"Transaction Amount: ".localized())
                     HStack{
                        Text("\(flow.amount)" + " ARRR")
                            .scaledFont(size: 15)
                            .frame(width: 300,alignment: .leading)
                         Spacer()
                     }
                     .frame(height: 40)
                    
                ConfirmTableSectionHeaderView(aTitle:"Processing fee: ".localized().localized())
                    HStack{
                        Text("\(Int64(ZECCWalletEnvironment.defaultFee).asHumanReadableZecBalance().toZecAmount())" + " ARRR")
                            .scaledFont(size: 15)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .frame(height: 40)
                   
                
                
            }
            .listRowBackground(ARRRBackground())
            .cornerRadius(0)
            .listStyle(PlainListStyle())
            .modifier(BackgroundPlaceholderModifierHome())
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.zGray, lineWidth: 1.0)
            )
            .padding()
         
         BlueButtonView(aTitle: "Confirm".localized()).onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
            NotificationCenter.default.post(name: NSNotification.Name("ConfirmedTransaction"), object: nil)
         }
         .frame(width: 100)
        }
        }.zcashNavigationBar(leadingItem: {
            EmptyView()
         }, headerItem: {
                HStack {
                    Text("Confirm Transaction")
                        .foregroundColor(.white)
                        .scaledFont(size: 20)
                        .multilineTextAlignment(.center)
                }
                .padding(.top,40)
         }, trailingItem: {
             ARRRCloseButton(action: {
                 presentationMode.wrappedValue.dismiss()
                 }).frame(width: 20, height: 20)
             .padding(.top,40)
         })

        .padding(.top,20)
        .padding(.bottom,20)
        
    }
}

struct ConfirmTableSectionHeaderView : View {
    @State var aTitle: String = ""

    var body: some View {
        
        ZStack {
            
            VStack(alignment: .trailing, spacing: 6) {

              Text(aTitle)
                .scaledFont(size: 17).foregroundColor(Color.zSettingsSectionHeader)
                                .foregroundColor(Color.white)
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 380)
           
        }
    }
}


struct ConfirmTransaction_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTransaction()
    }
}
