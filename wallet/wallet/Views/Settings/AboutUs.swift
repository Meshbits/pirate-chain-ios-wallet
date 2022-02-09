//
//  AboutUs.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 02/11/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AboutUs: View {
    @Environment(\.presentationMode) var presentationMode
    var anAppVersion = "App Version: 1.0.0"
    var aBuildversion = "Build: 10"
    var aCommitsCount = "Commits Count: 163"
    var aGitHash = "Short Git hash: g9eeb996"
    var aSourceCode = "Source: "
    var aSourceCodeURL = "https://github.com/Meshbits/pirate-chain-ios-wallet"
    var aDevelopedBy = "Developed by Meshbits Limited"
    var aVersionDetails = "Release: Beta"
    var mFontSize:CGFloat = Device.isLarge ? 15 : 12
    var mHeight:CGFloat = Device.isLarge ? 50 : 30
    
    var body: some View {
        
        ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack {

            List {
                
                 HStack{
                     Text(anAppVersion).multilineTextAlignment(.leading)
                         .lineLimit(nil)
                         .scaledFont(size: mFontSize)
                         .frame(alignment: .leading)
                     Spacer()
                 }
                 .listRowBackground(ARRRBackground())
                 .frame(minHeight: mHeight)
                
                 HStack{
                     Text(aBuildversion).multilineTextAlignment(.leading)
                         .lineLimit(nil)
                         .scaledFont(size: mFontSize)
                         .frame(alignment: .leading)
                     Spacer()
                 }
                 .listRowBackground(ARRRBackground())
                 .frame(minHeight: mHeight)
                
                HStack{
                    Text(aCommitsCount).multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .scaledFont(size: mFontSize)
                        .frame(alignment: .leading)
                    Spacer()
                }
                .listRowBackground(ARRRBackground())
                .frame(minHeight: mHeight)
                
                HStack{
                    Text(aGitHash).multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .scaledFont(size: mFontSize)
                        .frame(alignment: .leading)
                    Spacer()
                }
                .listRowBackground(ARRRBackground())
                .frame(minHeight: mHeight)
            
                HStack{
                    Text(aVersionDetails).multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .scaledFont(size: mFontSize)
                        .frame(alignment: .leading)
                    Spacer()
                }
                .listRowBackground(ARRRBackground())
                .frame(minHeight: mHeight)
               
                
                HStack{
                    Link(aSourceCode+aSourceCodeURL, destination: URL(string: aSourceCodeURL)!)
                        .scaledFont(size: mFontSize)
                    Spacer()
                }
                .listRowBackground(ARRRBackground())
                .frame(minHeight: mHeight)
                
            }
            .listRowBackground(ARRRBackground())
            .cornerRadius(0)
            .modifier(BackgroundPlaceholderModifierHome())
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.zGray, lineWidth: 1.0)
            )
            .padding()
         
                HStack{
                    Spacer()
                    Text(aDevelopedBy).multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .scaledFont(size: mFontSize)
                        .frame(alignment: .leading)
                    Spacer()
                }.padding()
        }
        }  .navigationBarBackButtonHidden(true)
            .navigationTitle("About Pirate Wallet".localized()).navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:  Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("backicon").resizable().frame(width: 50, height: 50)
                    }
                }
            })
    }
}

struct AboutUs_Previews: PreviewProvider {
    static var previews: some View {
        AboutUs()
    }
}
