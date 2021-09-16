//
//  CongratulationsRecoverySetup.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 31/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CongratulationsRecoverySetup: View {
    @EnvironmentObject var viewModel: WordsVerificationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var openAuthenticatateFaceID = false
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Congratulation! You completed your recovery phrase setup".localized()).padding(.trailing,30).padding(.leading,30).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,20)
                Text("You’re all set to deposit, receive, and store crypto in your Pirate wallet".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                Spacer(minLength: 10)
                Image("flag")
                    .padding(.trailing,80).padding(.leading,80)
                
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Done".localized()).onTapGesture {
                    openAuthenticatateFaceID = true
                }
                
                
                NavigationLink(
                    destination: AuthenticateFaceID().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                    isActive: $openAuthenticatateFaceID
                ) {
                    EmptyView()
                }
            }
           
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct CongratulationsRecoverySetup_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsRecoverySetup()
    }
}
