//
//  AddressFragmentWithoutNumber.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 24/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AddressFragmentWithoutNumber: View {
    
    var word: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(self.word)
                        .foregroundColor(.gray)
                        .scaledFont(size: 17)
                }
                .padding(.trailing, 4)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
                
            }
        }
    }
}


//struct AddressFragmentWithoutNumber_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressFragmentWithoutNumber()
//    }
//}
