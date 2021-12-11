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
    
    var dimension = Device.isLarge ? 265.0 :  225.0
    
    init(fillStyle: S) {
        self.fillStyle = fillStyle
    }
    
    var body: some View {
        ZStack {
           
            VStack (alignment: .center) {
                Image("splashicon").resizable().padding(.horizontal)
                    .frame(width: dimension, height: dimension, alignment: .center)
                
            }
        }
    }
}
