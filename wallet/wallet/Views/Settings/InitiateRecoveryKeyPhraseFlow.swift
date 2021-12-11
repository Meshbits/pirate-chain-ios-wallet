//
//  InitiateRecoveryKeyPhraseFlow.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 11/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct InitiateRecoveryKeyPhraseFlow: View {
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var validatePinBeforeInitiatingFlow = false
    @State var initiatePassphraseFlow = false
    
    var body: some View {
        ZStack{
//            ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, content: {
                    Spacer(minLength: 10)
                    Text("Write down your key again".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 26)).padding(.top,Device.isLarge ? 80 : 60)
                    Spacer(minLength: 10)
                    Image("hook")
                        .padding(.trailing,80).padding(.leading,80)
                    
                    Spacer(minLength: 10)
                    
                    Button {
                        validatePinBeforeInitiatingFlow = true
                       
                    } label: {
                        BlueButtonView(aTitle: "Continue".localized())
                    }
                 
                    NavigationLink(
                        destination: RecoveryWordsView().environmentObject(RecoveryWordsViewModel()).navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true),
                        isActive: $initiatePassphraseFlow
                    ) {
                        EmptyView()
                    }.isDetailLink(false)

                    Spacer(minLength: 10)
                })
            
            
            }
        .navigationBarHidden(true)
        .zcashNavigationBar(leadingItem: {
            Button {
                presentationMode.wrappedValue.dismiss()
          } label: {
              Image("backicon").resizable().frame(width: 50, height: 50).padding(.leading,-10)
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
        
        .sheet(isPresented: $validatePinBeforeInitiatingFlow) {
            LazyView(PasscodeValidationScreen(passcodeViewModel: PasscodeValidationViewModel(), isAuthenticationEnabled: false)).environmentObject(self.appEnvironment)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PasscodeValidationSuccessful")))
        { obj in
            initiatePassphraseFlow = true
        }
    }
}

struct InitiateRecoveryKeyPhraseFlow_Previews: PreviewProvider {
    static var previews: some View {
        InitiateRecoveryKeyPhraseFlow()
    }
}
