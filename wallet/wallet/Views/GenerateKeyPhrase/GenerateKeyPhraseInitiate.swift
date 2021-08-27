//
//  GenerateKeyPhraseInitiate.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 27/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct GenerateKeyPhraseInitiate: View {
    var body: some View {
        NavigationView{
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, content: {
                    Text("Generate your private recovery phrase").padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                    Text("The key is required to recover your money if you upgrade or lose your phone").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                    Spacer()
                    Spacer()
                    
                    Button {
                        // open next screen
                    } label: {
                        BlueButtonView(aTitle: "Continue")
                    }

                })
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GenerateKeyPhraseInitiate_Previews: PreviewProvider {
    static var previews: some View {
        GenerateKeyPhraseInitiate()
    }
}
