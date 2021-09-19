//
//  CongratulationsFaceID.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 02/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CongratulationsFaceID: View {
    @EnvironmentObject var viewModel: WordsVerificationViewModel
    @State var openWalletSetupScreen = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Congratulation! \nFace ID setup successfully".localized()).padding(.trailing,30).padding(.leading,30).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,40)
                Text("You have successfuly enabled Face ID based authentication. \n\nNow securely login using your Face ID".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                Spacer(minLength: 10)
                Image("flag")
                    .padding(.trailing,80).padding(.leading,80)
                
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Login".localized()).onTapGesture {
                    openWalletSetupScreen = true
                }
                
                NavigationLink(
                    destination: CreateAndSetupNewWallet().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                    isActive: $openWalletSetupScreen
                ) {
                    EmptyView()
                }
                
            }
           
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct CongratulationsFaceID_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsFaceID()
    }
}
