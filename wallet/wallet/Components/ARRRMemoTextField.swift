//
//  ARRRMemoTextField.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 24/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ARRRMemoTextField: View {
    
    var paragraphStyle: NSParagraphStyle {
        let p = NSMutableParagraphStyle()
        p.firstLineHeadIndent = 50
        return p
    }
    
    @State var memoText = ""
    
    @State var isReplyTo = true
    
    var body: some View {
        ZStack{
           
            HStack{
                  TextField("Memo Text...", text: $memoText)
                  .font(.barlowRegular(size: 20))
                  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.clear))
                  .foregroundColor(Color.gray)
                  .modifier(QRCodeBackgroundPlaceholderModifier())
                  .padding(.leading, 10)
                
                Spacer()
                VStack{
                    Toggle(isOn: $isReplyTo) {
                        Text("")
                    }
                    .toggleStyle(ARRRToggleStyle(isHighlighted: $isReplyTo))
                    Text("Reply to").font(.barlowRegular(size: 12)).foregroundColor(.gray)
                }.padding(.trailing, 10)
                Spacer()
            }
        }
    }
}

struct ARRRMemoTextField_Previews: PreviewProvider {
    static var previews: some View {
        ARRRMemoTextField()
    }
}
