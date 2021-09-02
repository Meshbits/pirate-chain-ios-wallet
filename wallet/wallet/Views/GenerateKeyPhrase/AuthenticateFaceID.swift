//
//  AuthenticateFaceID.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 01/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AuthenticateFaceID: View {
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Authenticate Face ID").padding(.trailing,30).padding(.leading,30).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,20)
                Text("Login quickly using your Face ID").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                Spacer(minLength: 10)

                Spacer(minLength: 10)
             
                HStack{
                    
                    SmallRecoveryWalletButtonView(imageName: Binding.constant("buttonbackground"), title: Binding.constant("Skip")).onTapGesture {
                        
                    }
                    
                    SmallBlueButtonView(aTitle: "Allow").onTapGesture {
                        // Initiate Authentication flow
                    }
                }.padding(60)
                
            }
           
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct AuthenticateFaceID_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateFaceID()
    }
}



struct SmallRecoveryWalletButtonView : View {
    
    @Binding var imageName: String
    @Binding var title: String

    
    
    var body: some View {
        ZStack {

            Image(imageName).resizable().frame(width: 145.0, height:84).padding(.top,5)
            
            Text(title).foregroundColor(Color.zARRRTextColorLightYellow)
                .frame(width: 145.0, height:84).padding(10)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 145.0, height:84)
    }
}


struct SmallBlueButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bluebuttonbackground").resizable().frame(width: 145.0, height:84).padding(.top,5)
            
            Text(aTitle).foregroundColor(Color.black)
                .frame(width: 145.0, height:84)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 145.0, height:84)
        
    }
}
