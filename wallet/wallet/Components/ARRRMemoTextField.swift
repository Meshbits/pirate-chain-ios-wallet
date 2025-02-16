//
//  ARRRMemoTextField.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 24/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ARRRMemoTextField: View {
   
    @Binding var memoText:String
    
    @State var isReplyTo = true
    
    var body: some View {
        ZStack{
           
            HStack{
                TextField("Memo Text...".localized(), text: $memoText)
                  .scaledFont(size: 20)
                  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.clear))
                  .foregroundColor(Color.white)
                  .modifier(QRCodeBackgroundPlaceholderModifier())
                
                Spacer()
                VStack{
                    Toggle(isOn: $isReplyTo) {
                        Text("")
                    }
                    .toggleStyle(ARRRToggleStyle(isHighlighted: $isReplyTo))
                    Text("Reply to".localized())
                        .scaledFont(size: 14).foregroundColor(.gray)
                }.padding(.trailing, 10)
                Spacer()
            }
        }
    }
    
    
    var paragraphStyle: NSParagraphStyle {
        let p = NSMutableParagraphStyle()
        p.firstLineHeadIndent = 50
        return p
    }
    
}
//
//struct ARRRMemoTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        ARRRMemoTextField()
//    }
//}
