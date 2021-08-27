//
//  ARRRBackButton.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 27/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct ARRRBackButton: View {
    var action: () -> Void
    
    var body: some View {
        
        ZStack {
            Image("passcodenumericbg")

            Button(action: {
                self.action()
            }) {
                Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).font(
                    .barlowRegular(size: Device.isLarge ? 26 : 18))
            }
        }.padding(2)
        
       
    }
}


struct ARRRBackButton_Previews: PreviewProvider {
    static var previews: some View {
        ARRRBackButton {
            
        }
    }
}
