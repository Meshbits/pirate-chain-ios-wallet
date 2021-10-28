//
//  OpenInAppBrowser.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 18/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import WKView

struct OpenInAppBrowser: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var aURLString:String
    @State var aTitle:String
    
    var body: some View
    {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
                
            WebView(url: aURLString,
                        tintColor: Color.gray,
                        titleColor: .yellow,
                        backText: Text("").italic(),
                        reloadImage: Image(""),
                        goForwardImage: Image(systemName: "forward.frame.fill"),
                        goBackImage: Image(systemName: "backward.frame.fill"),
                        title:aTitle
             )
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(aTitle, displayMode: .inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
              Button {
                  presentationMode.wrappedValue.dismiss()
              } label: {
                  Image("backicon").resizable().frame(width: 60, height: 60)
              }
        })
    }
}
