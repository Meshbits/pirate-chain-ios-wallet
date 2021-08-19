//
//  PrivateServerConfig.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 15/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct PrivateServerConfig: View {
    @State private var lightServerString: String = SeedManager.default.exportLightWalletEndpoint()
    @State private var lightPortString: String = String.init(format:"%d",SeedManager.default.exportLightWalletPort())
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var isAutoConfigEnabled = true
    @State var isDisplayAddressAlert = false
    @State var isDisplayPortAlert = false
    @State var isUserEditingPort = false
    @State var isUserEditingAddress = false

    
    var isHighlightedAddress: Bool {
        lightServerString.count > 0
    }
    
    var isHighlightedPort: Bool {
        lightPortString.count > 0
    }

    var body: some View {
        ZStack{
             
            ARRRBackground()
          
            VStack(alignment: .center, spacing: 5){

                Text("Private Server Config").foregroundColor(.gray).font(.barlowRegular(size: 20)).multilineTextAlignment(.center).foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 10) {
                     HStack {
                         Text("Auto Config").foregroundColor(.gray).font(.barlowRegular(size: 14)).multilineTextAlignment(.center).foregroundColor(.white)
                         
                         Toggle("", isOn: $isAutoConfigEnabled)
                             .toggleStyle(ColoredToggleStyle()).labelsHidden()
                     }
                     Divider().foregroundColor(.white).frame(height:2).padding()
                     
                     VStack(alignment: .leading, spacing: nil, content: {
                         Text("Chain lite server ").font(.barlowRegular(size: 14)).foregroundColor(.gray).multilineTextAlignment(.leading)
                        
                        TextField("".localized(), text: $lightServerString, onEditingChanged: { (changed) in
                                isUserEditingAddress = true
                        }) {
                            isUserEditingAddress = false
                            self.didEndEditingAddressTextField()
                        }.font(.barlowRegular(size: 14))
                        .modifier(BackgroundPlaceholderModifier())
                        
                       Text("Port ").foregroundColor(.gray).multilineTextAlignment(.leading).font(.barlowRegular(size: 14))
                                     
                       TextField("".localized(), text: $lightPortString, onEditingChanged: { (changed) in
                           isUserEditingPort = true
                       }) {
                           isUserEditingPort = false
                           self.didEndEditingPortTextField()
                       }.font(.barlowRegular(size: 14))
                       .modifier(BackgroundPlaceholderModifier())
                                                
                     }).modifier(ForegroundPlaceholderModifier())
                 }
                 .modifier(BackgroundPlaceholderModifier())
                 
               
                Spacer(minLength: 10)
                
            }.padding(.top, 100)
            
        }
        .onTapGesture {
                       
               if isUserEditingPort {
                   isUserEditingPort = false
                   self.didEndEditingPortTextField()
               }
               
               if isUserEditingAddress {
                   isUserEditingAddress = false
                   self.didEndEditingAddressTextField()
               }
               
               UIApplication.shared.endEditing()

        }
        .alert(isPresented: self.$isDisplayAddressAlert, content: { () -> Alert in
                       Alert(title: Text("".localized()),
                             message: Text("Invalid Lite Server Address, Reverting it to pirate chain address!".localized()),
                             dismissButton: .default(Text("button_close".localized()),action: {
                               lightServerString = ZECCWalletEnvironment.defaultLightWalletEndpoint
                               SeedManager.default.importLightWalletEndpoint(address: lightServerString)
                         }))
                   })
                   .alert(isPresented: self.$isDisplayPortAlert, content: { () -> Alert in
                       Alert(title: Text("".localized()),
                             message: Text("Invalid Lite Server Port, Reverting it to pirate chain port!".localized()),
                             dismissButton: .default(Text("button_close".localized()),action: {
                               lightPortString = String.init(format: "%d", ZECCWalletEnvironment.defaultLightWalletPort)
                               SeedManager.default.importLightWalletPort(port: Int(lightPortString) ?? ZECCWalletEnvironment.defaultLightWalletPort)
                         }))
           })
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack(alignment: .leading) {
                ZStack{
                    Image("passcodenumericbg")
                    Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).font(
                        .barlowRegular(size: Device.isLarge ? 26 : 18)
                    ).padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
                }
            }.padding(.leading,-20).padding(.top,10)
        })
    }
    
    
       func didEndEditingAddressTextField(){
           if lightServerString.count == 0 {
               isDisplayAddressAlert = true
           }else{
               SeedManager.default.importLightWalletEndpoint(address: lightServerString)
           }
       }
       
       func didEndEditingPortTextField(){
        if lightPortString.count == 0 {
               isDisplayPortAlert = true
        }else{
               // save port
            SeedManager.default.importLightWalletPort(port: Int(lightPortString) ?? ZECCWalletEnvironment.defaultLightWalletPort)
        }
       }
}

struct PrivateServerConfig_Previews: PreviewProvider {
    static var previews: some View {
        PrivateServerConfig()
    }
}


struct BackgroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
        .padding()
    }
}



struct ForegroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), lightShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), spread: 0.05, radius: 2))
        .padding()
    }
}