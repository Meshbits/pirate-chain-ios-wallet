//
//  WordsVerificationScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 28/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct WordsVerificationScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Confirm Recovery Phrase").padding(.trailing,80).padding(.leading,80).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text("Almost done! Enter the following words from your recovery phrase").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                Spacer()
                
                BlueButtonView(aTitle: "Confirm")
            }
        }
        
    }
}

struct WordsVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        WordsVerificationScreen()
    }
}
