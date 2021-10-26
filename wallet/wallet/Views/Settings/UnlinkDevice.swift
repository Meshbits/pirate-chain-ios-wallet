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
//                    ARRRBackground().edgesIgnoringSafeArea(.all)
                        VStack(alignment: .center, content: {
                            Spacer(minLength: 10)
                            Text("Unlink your wallet from this device".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                                .scaledFont(size: 32).padding(.top,40)
                            Text("Start a new wallet by unlinking your device from the currently installed wallet".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: 15)
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
                .navigationBarHidden(true)
                .zcashNavigationBar(leadingItem: {
                    Button {
                      presentationMode.wrappedValue.dismiss()
                  } label: {
                      Image("backicon").resizable().frame(width: 60, height: 60)
                  }
                    
                }, headerItem: {
                    HStack{
                        EmptyView()
                    }
                }, trailingItem: {
                    HStack{
                        EmptyView()
                    }
                })
                .onAppear(){
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("NukedUser"), object: nil, queue: .main) { (_) in
                        UserSettings.shared.removeAllSettings()
                        ZECCWalletEnvironment.shared.nuke(abortApplication: false)
    //                                            try! self.appEnvironment.deleteWalletFiles()
    //                                            presentationMode.wrappedValue.dismiss()
                        ZECCWalletEnvironment.shared.state = .uninitialized
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              NotificationCenter.default.post(name: NSNotification.Name("MoveToFirstViewLayout"), object: nil)
                        }
                    }
                }
    }
}

struct UnlinkDevice_Previews: PreviewProvider {
    static var previews: some View {
        UnlinkDevice()
    }
}
