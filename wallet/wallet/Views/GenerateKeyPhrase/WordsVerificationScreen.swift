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
            Text("Your Recovery Phrase").padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
        }
        
    }
}

struct WordsVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        WordsVerificationScreen()
    }
}
