//
//  UnlinkDevice.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 15/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct UnlinkDevice: View {
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var goToRecoveryPhrase = false
    var body: some View {
                ZStack{
                        ARRRBackground()
                        VStack(alignment: .center, content: {
                            Spacer(minLength: 10)
                            Text("Unlink your wallet from this device".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                            Text("Start a new wallet by unlinking your device from the currently installed wallet".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 16 : 10))
                            Spacer(minLength: 10)
                            Image("bombIcon")
                                .padding(.trailing,80).padding(.leading,80)
                            
                            Spacer(minLength: 10)
                            Button {
                                goToRecoveryPhrase = true
                               
                            } label: {
                                BlueButtonView(aTitle: "Continue".localized())
                                
                            }
                            
                            NavigationLink(
                                destination: RecoveryBasedUnlink().environmentObject(RecoveryViewModel()).navigationBarTitle("", displayMode: .inline)
                                    .navigationBarBackButtonHidden(true),
                                isActive: $goToRecoveryPhrase
                            ) {
                               EmptyView()
                            }
                            
                            Spacer(minLength: 10)
                        })
                    
                    
                    }.edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("passcodenumericbg")
                            Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).font(
                                .barlowRegular(size: Device.isLarge ? 26 : 18)
                            ).padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
                        }
                    }.padding(.leading,-20).padding(.top,10)
                })
    }
}

struct UnlinkDevice_Previews: PreviewProvider {
    static var previews: some View {
        UnlinkDevice()
    }
}
