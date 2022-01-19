//
//  AuthenticateFaceID.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 01/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct AuthenticateFaceID: View {
    
    @EnvironmentObject var viewModel: WordsVerificationViewModel

    @State var skipAndMoveToHomeTab = false
    
    @State var skipAndMoveToCongratulationsAfterFaceIDSuccess = false
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Authenticate Biometric ID".localized()).padding(.trailing,30).padding(.leading,30).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).scaledFont(size: Device.isLarge ? 22 : 16).padding(.top,50)
                Text("Login quickly using your Biometric ID".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: Device.isLarge ? 14 : 11)
                
                Spacer(minLength: 10)

                Spacer(minLength: 10)
             
                HStack{
                    
                    SmallRecoveryWalletButtonView(imageName: Binding.constant("buttonbackground"), title: Binding.constant("Skip".localized())).onTapGesture {
                        skipAndMoveToHomeTab = true
                    }
                    
                    SmallBlueButtonView(aTitle: "Allow".localized()).onTapGesture {
                        initiateFaceIDAuthentication()
                    }
                    
                    
                }.padding(60)
                

                NavigationLink(
                    destination: CongratulationsFaceID().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                    isActive: $skipAndMoveToCongratulationsAfterFaceIDSuccess
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: CreateAndSetupNewWallet().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                    isActive: $skipAndMoveToHomeTab
                ) {
                    EmptyView()
                }
            }
           
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
            switch output {
            case .failed(_), .userFailed:
                print("SOME ERROR OCCURRED")
                UserSettings.shared.isBiometricDisabled = true
                skipAndMoveToHomeTab = true

            case .success:
                print("SUCCESS IN AUTH FACE ID")
                UserSettings.shared.biometricInAppStatus = true
                UserSettings.shared.isBiometricDisabled = false
                skipAndMoveToCongratulationsAfterFaceIDSuccess = true
            case .userDeclined:
                print("DECLINED AND SHOW SOME ALERT HERE")
                UserSettings.shared.biometricInAppStatus = false
                UserSettings.shared.isBiometricDisabled = true
                skipAndMoveToHomeTab = true

                break
            }
        }
    }
    
    func initiateFaceIDAuthentication(){
        AuthenticationHelper.authenticate(with: "Authenticate Biometric ID".localized())
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

            Image(imageName).resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(title).foregroundColor(Color.zARRRTextColorLightYellow)
                .frame(width: 175.0, height:84).padding(10)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
    }
}


struct SmallBlueButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bluebuttonbackground").resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(aTitle).foregroundColor(Color.black)
                .frame(width: 175.0, height:84)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
        
    }
}
