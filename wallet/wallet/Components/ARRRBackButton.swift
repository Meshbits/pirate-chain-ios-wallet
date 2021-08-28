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

            Button(action: {
                self.action()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("passcodenumericbg")
                        Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
                    }
                }.padding(.leading,-10).padding(.top,10)
            }
        }.padding(5)
        
       
    }
}


struct ARRRBackButton_Previews: PreviewProvider {
    static var previews: some View {
        ARRRBackButton {
            
        }
    }
}
