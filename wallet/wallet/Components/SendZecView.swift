//
//  SendZecView.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct SendZecView: View {
    
    @Binding var zatoshi: String
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
  
            Image("piratelogoicon").frame(width: 20, height: 20, alignment: .top).offset(x: 0, y: -20)
            Text("\(self.$zatoshi.wrappedValue)")
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundColor(.white)
            .font(
                .custom("Zboto", size: 72)
            )

        }
    }
}

struct SendZecView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            SendZecView(zatoshi: .constant("12.345"))
        }
    }
}
