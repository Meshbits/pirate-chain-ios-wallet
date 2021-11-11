//
//  ARRRCloseButton.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 20/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Neumorphic

struct ARRRCloseButton: View {
    var action: () -> Void
    
    var body: some View {
        
        ZStack {
//            Image("passcodenumericbg")

            Button(action: {
                self.action()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("closebutton").resizable().frame(width: 70, height: 70)
                    }
                }
            }
        }.padding(2)
        
       
    }
}
