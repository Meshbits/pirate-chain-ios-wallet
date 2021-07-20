//
//  ARRRLogo.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 20/07/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import UIKit
import SwiftUI

struct ARRRLogo<S: ShapeStyle>: View {

    var fillStyle: S
    
    
    init(fillStyle: S) {
        self.fillStyle = fillStyle
    }
    
    var body: some View {
        ZStack {
           
            VStack (alignment: .center) {
                Image("splashicon").padding(.horizontal)
                    .frame(width: 225.0, height:84, alignment: .center)
                
            }
        }
    }
}
