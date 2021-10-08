//
//  PasscodeValidationScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 29/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import AlertToast
import Combine
import LocalAuthentication

public class PasscodeValidationViewModel: ObservableObject{
    
    @Published var mStateOfPins: [Bool] = [false,false,false,false,false,false] // To change the color of pins
    
    @Published var mPressedKeys: [Int] = [] // To keep the pressed content
    
    @Published var mPasscodeValidationFailure = false
    
    @Published var mDismissAfterValidation = false
    
    var aTempPasscode = ""
        
    var aSavedPasscode = UserSettings.shared.aPasscode

    var cancellable: AnyCancellable?
    
    init() {
        
    }
    
    func captureKeyPress(mKeyPressed:Int,isBackPressed:Bool){
        
        let mCurrentSelectedNumber = mKeyPressed
        
        if isBackPressed {
            
            if mPressedKeys.count > 0 {
                mPressedKeys.removeLast()
            }

            return
        }
        
        if mPressedKeys.count < 6 {
            
            mPressedKeys.append(mCurrentSelectedNumber)
            
        }
        
        if mPressedKeys.count == 6 {
            comparePasscodes()
        }

    }
   
    func comparePasscodes(){
        
        aTempPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
        
        if !aTempPasscode.isEmpty {
            if aTempPasscode == aSavedPasscode {
                mDismissAfterValidation = true
            }else{
                mPasscodeValidationFailure = true
                mStateOfPins = mStateOfPins.map { _ in false }
                mPressedKeys.removeAll()
                aTempPasscode = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.mPasscodeValidationFailure = false
                }
            }
        }
    }
    
    func updateLayout(isBackPressed:Bool){
        
        if mPressedKeys.count == 0 {
            mStateOfPins = mStateOfPins.map { _ in false }
            return
        }
        
       var mCurrentSelectedIndex = -1

       for index in 0 ..< mStateOfPins.count {
        if mStateOfPins[index] {
               mCurrentSelectedIndex = index
           }
       }

        if !isBackPressed {
            mCurrentSelectedIndex += 1
        }
        
        if mCurrentSelectedIndex < mStateOfPins.count && mPressedKeys.count > 0 {
            
            if isBackPressed {
                mStateOfPins[mCurrentSelectedIndex] = false
            }else{
                mStateOfPins[mCurrentSelectedIndex] = true
            }
           
        }
    }
    
}


struct PasscodeValidationScreen: View {
    
    @ObservedObject var passcodeViewModel = PasscodeValidationViewModel()
    
    @State var validateAndDismiss = false
    
    @State var isAuthenticationEnabled:Bool
    
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
      
    let dragGesture = DragGesture()
    
    var body: some View {

        ZStack {

            PasscodeBackgroundView()
            
           
            VStack(alignment: .center, spacing: 10, content: {
                HStack{
                    Spacer()
                    ARRRCloseButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                    .hidden(isAuthenticationEnabled)
                    .frame(width: 30, height: 30).padding(.top,30).multilineTextAlignment(.trailing)
                    .padding(.trailing,30)
                    
                }
                
                Spacer()
                HStack(alignment: .center, spacing: nil, content: {
                    Spacer()
                    Text("Enter PIN".localized()).foregroundColor(.white).scaledFont(size: 28).padding(.top,20)
                    Spacer()
                })

                PasscodeScreenDescription(aDescription: "Please enter your PIN to proceed".localized(),size:20,padding:50)
                Spacer()
                
                HStack(alignment: .center, spacing: 0, content: {
                    ForEach(0 ..< passcodeViewModel.mStateOfPins.count) { index in
                        PasscodePinImageView(isSelected: Binding.constant(passcodeViewModel.mStateOfPins[index]))
                    }
                }).padding(20)
                
                PasscodeValidationNumberView(passcodeViewModel: Binding.constant(passcodeViewModel))
                         
            }).padding(.top,30)
            
        }
        .highPriorityGesture(dragGesture)
        .toast(isPresenting: Binding.constant(passcodeViewModel.mPasscodeValidationFailure)){
            AlertToast(displayMode: .hud, type: .regular, title:"Invalid passcode!".localized())

        }
        .onAppear(){
            
            self.passcodeViewModel.cancellable = self.passcodeViewModel
                            .$mDismissAfterValidation
                            .sink(receiveValue: { isDismiss in
                                guard isDismiss else { return }
                                if (isDismiss){
                                    self.presentationMode.wrappedValue.dismiss()
                                    NotificationCenter.default.post(name: NSNotification.Name("PasscodeValidationSuccessful"), object: nil)
                                }
                            }
            )
            
            if(isAuthenticationEnabled){
                authenticate()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
                   switch output {
                   case .failed(_), .userFailed:
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                   case .success:
                        UserSettings.shared.biometricInAppStatus = true
                        UserSettings.shared.isBiometricDisabled = false
                        self.passcodeViewModel.mDismissAfterValidation = true
                   case .userDeclined:
                        UserSettings.shared.biometricInAppStatus = false
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                       break
                   }
            

       }
    }
    
    func authenticate() {
        if UserSettings.shared.biometricInAppStatus{
            AuthenticationHelper.authenticate(with: "Authenticate Biometric".localized())
        }
    }
}

//struct PasscodeValidationScreen_Previews: PreviewProvider {
//    static var previews: some View {
////        PasscodeValidationScreen()
//    }
//}


extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
