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
                    ARRRBackground().edgesIgnoringSafeArea(.all)
                        VStack(alignment: .center, content: {
                            Spacer(minLength: 10)
                            Text("Delete your wallet from this device".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                                .scaledFont(size: 26).padding(.top,40)
                            Text("Start a new wallet by deleting your device from the currently installed wallet".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: 15)
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
                                destination: RecoveryBasedUnlink().environmentObject(RecoveryViewModel()),
                                isActive: $goToRecoveryPhrase
                            ) {
                               EmptyView()
                            }
                            
                            Spacer(minLength: 10)
                        })
                    
                    
                    }.edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("").navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("backicon").resizable().frame(width: 50, height: 50)
                        }
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
