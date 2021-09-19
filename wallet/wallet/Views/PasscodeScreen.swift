//
//  PasscodeScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 20/07/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

import LocalAuthentication

public class PasscodeViewModel: ObservableObject{
    
    @Published var mStateOfPins: [Bool] = [false,false,false,false,false,false] // To change the color of pins
    
    @Published var mPressedKeys: [Int] = [] // To keep the pressed content
    
    var aTempPasscode = ""
        
    var aTempConfirmPasscode = ""
    
    var aSavedPasscode = UserSettings.shared.aPasscode
    
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
    
    func getTemporaryPasscode()->String {
        return aTempPasscode
    }
    
    func comparePasscodes(){
        
        if !aTempPasscode.isEmpty {
            aTempConfirmPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            if aTempPasscode == aTempConfirmPasscode {
                UserSettings.shared.aPasscode = aTempPasscode
                print("PASSCODE ARE SAME")
            }else{
                print("PASSCODE ARE NOT SAME")
            }
            NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
        }else{
            aTempPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
        }
        
        
    }
    
    func updateLayout(isBackPressed:Bool){
       var mCurrentSelectedIndex = -1

       for index in 0 ..< mStateOfPins.count {
        if mStateOfPins[index] {
               mCurrentSelectedIndex = index
           }
       }

        if !isBackPressed {
            mCurrentSelectedIndex += 1
        }

       if mCurrentSelectedIndex < mStateOfPins.count {
        
        if isBackPressed {
            mStateOfPins[mCurrentSelectedIndex] = false
        }else{
            mStateOfPins[mCurrentSelectedIndex] = true
        }
           
       }
    }
    
}

struct PasscodeScreen: View {
    
   @ObservedObject var passcodeViewModel = PasscodeViewModel()
    
    @State var openHomeScreen = false
    @State var initiateNewWalletPhraseSetup = false
    
    enum Destinations: Int {
        case createNew
        case restoreWallet
    }
    
    enum AlertType: Identifiable {
        case feedback(destination: Destinations, cause: Error)
        case error(cause:Error)
        var id: Int {
            switch self {
            case .error:
                return 0
            case .feedback:
                return 1
            }
        }
    }
    
    
    enum PasscodeScreenStates: Int {
        case none = 0
        case validatePasscode = 1
        case newPasscode = 2
        case confirmPasscode = 3
        case passcodeAlreadyExists = 4
        case changePasscode = 5
        case validateAndDismiss = 6
    }

    
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
      
    @State var error: UserFacingErrors?
    @State var showError: AlertType?
    @State var destination: Destinations?
    
    let dragGesture = DragGesture()
   
   @State var mScreenState: PasscodeScreenStates?
    
   @State var isNewWallet = false
    
   @State var isAuthenticatedFlowInitiated = false
    
   @State var isFirstTimeSetup = false
        
    var body: some View {
        ZStack {
            
//            NavigationLink(destination:
//                LazyView (
//                    BackupWallet().environmentObject(self.appEnvironment)
//                    .navigationBarHidden(true)
//                ),
//                           tag: Destinations.createNew,
//                           selection: $destination
//
//            ) {
//              EmptyView()
//            }
            
            NavigationLink(destination:                
                    GenerateKeyPhraseInitiate().environmentObject(self.appEnvironment)
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                ,isActive: $initiateNewWalletPhraseSetup
            ) {
                EmptyView()
            }.isDetailLink(false)
            
            
            PasscodeBackgroundView()
            
            VStack(alignment: .center, spacing: 10, content: {
                
                if mScreenState == PasscodeScreenStates.passcodeAlreadyExists{
                    PasscodeScreenTopImageView().padding(.leading,20).padding(.top,50)
                }else if mScreenState == PasscodeScreenStates.validatePasscode{
                    PasscodeScreenTitle(aTitle: "LOGIN PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "Enter PIN".localized())
                    PasscodeScreenDescription(aDescription: "Please enter your PIN to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 18 : 12,padding:50)
                    Spacer()
                }else if mScreenState == PasscodeScreenStates.validateAndDismiss{
                    PasscodeScreenTitle(aTitle: "Enter PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "PIN Required".localized())
                    PasscodeScreenDescription(aDescription: "Please enter your PIN to conotinue".localized(),size:Device.isLarge ? 18 : 12,padding:50)
                    Spacer()
                }else if mScreenState == PasscodeScreenStates.newPasscode{
                    PasscodeScreenTitle(aTitle: "Change PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "SET PIN".localized())
                    PasscodeScreenDescription(aDescription: "Your PIN will be used to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 18 : 12,padding:50)
                    Spacer()
                }else if mScreenState == PasscodeScreenStates.confirmPasscode{
                    PasscodeScreenTitle(aTitle: "Change PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "Re-Enter PIN".localized())
                    PasscodeScreenDescription(aDescription: "Your PIN will be used to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 18 : 12,padding:50)
                    Spacer()
                }
                
                HStack(alignment: .center, spacing: 0, content: {
                    
                    ForEach(0 ..< passcodeViewModel.mStateOfPins.count) { index in
                        PasscodePinImageView(isSelected: Binding.constant(passcodeViewModel.mStateOfPins[index]))
                    }
                }).padding(20)

                PasscodeScreenDescription(aDescription: "Remember your PIN. If you forget it, you won't be able to access your assets.".localized(),size:Device.isLarge ? 14 : 8,padding:90)
                
                PasscodeNumberView(passcodeViewModel: Binding.constant(passcodeViewModel))
                                
            })
            
            NavigationLink(destination:
                            HomeTabView(openPasscodeScreen: false)
                                .environmentObject(appEnvironment)
            , isActive: $openHomeScreen) {
                EmptyView()
            }.isDetailLink(false)
            
        }
        .highPriorityGesture(dragGesture)
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateLayout"), object: nil, queue: .main) { (_) in
                
                if let aPasscode = UserSettings.shared.aPasscode, !aPasscode.isEmpty{
                    
                    let aTempPasscode = passcodeViewModel.getTemporaryPasscode()
                    
                    if !aTempPasscode.isEmpty && aTempPasscode == aPasscode{
                        
                        if handleUseCasesRelatedToScreenStates() {
                            return
                        }

                        if isNewWallet {
                            // Initiate Create New Wallet flow from here
//                            createNewWalletFlow()
                            initiateNewWalletPhraseSetup = true
                            return
                        }else{

                            if (!isFirstTimeSetup){
                                if UIApplication.shared.windows.count > 0 {
                                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                                }
                            }
                            
                            openHomeScreen = true

                            return
                        }
                    }
                }
                
                if mScreenState == PasscodeScreenStates.newPasscode {
                    mScreenState = PasscodeScreenStates.confirmPasscode
                    passcodeViewModel.mStateOfPins = passcodeViewModel.mStateOfPins.map { _ in false }
                    passcodeViewModel.mPressedKeys.removeAll()
                }
            }
            
            authenticate()

        }
        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
                   switch output {
                   case .failed(_), .userFailed:
                       print("SOME ERROR OCCURRED")
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)

                   case .success:
                       print("SUCCESS IN PASSCODE")
                        UserSettings.shared.biometricInAppStatus = true
                        UserSettings.shared.isBiometricDisabled = false
                        if mScreenState == PasscodeScreenStates.validatePasscode {
                            openHomeScreen = true
                            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                        }else{
                            // Handle other use case here
                            if handleUseCasesRelatedToScreenStates() {
                                return
                            }
                        }
                   case .userDeclined:
                       print("DECLINED")
                        UserSettings.shared.biometricInAppStatus = false
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                       break
                   }
            

       }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
            .alert(item: self.$showError) { (alertType) -> Alert in
                switch alertType {
                case .error(let cause):
                    let userFacingError = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: cause))
                    return Alert(title: Text(userFacingError.title),
                                 message: Text(userFacingError.message),
                                 dismissButton: .default(Text("button_close".localized())))
                case .feedback(let destination, let cause):
                    if let feedbackCause = cause as? SeedManager.SeedManagerError,
                       case SeedManager.SeedManagerError.alreadyImported = feedbackCause {
                        return existingCredentialsFound(originalDestination: destination)
                    } else {
                        return defaultAlert(cause)
                    }

                }
            }
    }
    
    func handleUseCasesRelatedToScreenStates()->Bool{
        
        var isReturnFromFlow = false
        
        switch mScreenState {
            case .validateAndDismiss:
                presentationMode.wrappedValue.dismiss()
                mScreenState = .validateAndDismiss
                NotificationCenter.default.post(name: NSNotification.Name("ValidationSuccessful"), object: nil)
                isReturnFromFlow = true
            default:
                print("Default case")
        }
        
        return isReturnFromFlow
    }
    
    func createNewWalletFlow(){
        do {
            tracker.track(.tap(action: .landingBackupWallet), properties: [:])
            try self.appEnvironment.createNewWallet()
            openHomeScreen = true
        } catch WalletError.createFailed(let e) {
            if case SeedManager.SeedManagerError.alreadyImported = e {
                self.showError = AlertType.feedback(destination: .createNew, cause: e)
            } else {
                fail(WalletError.createFailed(underlying: e))
            }
        } catch {
            fail(error)
        }
    }
    
    func fail(_ error: Error) {
        let message = "could not create new wallet:".localized()
        logger.error("\(message) \(error)")
        tracker.track(.error(severity: .critical),
                      properties: [
                        ErrorSeverity.messageKey : message,
                        ErrorSeverity.underlyingError : "\(error)"
                        ])
       
       self.showError = .error(cause: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
        
    }
    
    func existingCredentialsFound(originalDestination: Destinations) -> Alert {
        Alert(title: Text("Existing keys found!".localized()),
              message: Text("it appears that this device already has keys stored on it. What do you want to do?".localized()),
              primaryButton: .default(Text("Restore existing keys".localized()),
                                      action: {
                                        do {
                                            try ZECCWalletEnvironment.shared.initialize()
                                            self.destination = .createNew
                                        } catch {
                                            DispatchQueue.main.async {
                                                self.fail(error)
                                            }
                                        }
                                      }),
              secondaryButton: .destructive(Text("Discard them and continue".localized()),
                                            action: {
                                                
                                                ZECCWalletEnvironment.shared.nuke(abortApplication: false)
                                                do {
                                                    try ZECCWalletEnvironment.shared.reset()
                                                } catch {
                                                    self.fail(error)
                                                    return
                                                }
                                                switch originalDestination {
                                                case .createNew:
                                                    do {
                                                        try self.appEnvironment.createNewWallet()
                                                        self.destination = originalDestination
                                                    } catch {
                                                            self.fail(error)
                                                    }
                                                case .restoreWallet:
                                                    self.destination = originalDestination
                                                
                                                }
                                            }))
    }
    
    
    func defaultAlert(_ error: Error? = nil) -> Alert {
        guard let e = error else {
            return Alert(title: Text("Error Initializing Wallet".localized()),
                 message: Text("There was a problem initializing the wallet".localized()),
                 dismissButton: .default(Text("button_close".localized())))
        }
        
        return Alert(title: Text("Error".localized()),
                     message: Text(mapToUserFacingError(ZECCWalletEnvironment.mapError(error: e)).message),
                     dismissButton: .default(Text("button_close".localized())))
        
    }
    
    func authenticate() {
        if UserSettings.shared.biometricInAppStatus && mScreenState != .newPasscode && !isAuthenticatedFlowInitiated{
            isAuthenticatedFlowInitiated = true
            AuthenticationHelper.authenticate(with: "Authenticate Biometric".localized())
        }
    }
}

struct PasscodeNumber: View {
    
    @Binding var passcodeValue: String
    
    @Binding var passcodeViewModel: PasscodeViewModel
    
    var body: some View {
        
            Button(action: {
                passcodeViewModel.updateLayout(isBackPressed: passcodeValue == "delete" ? true : false)
                
                if passcodeValue == "delete" {
                    passcodeViewModel.captureKeyPress(mKeyPressed: -1, isBackPressed: true)
                }else{
                    passcodeViewModel.captureKeyPress(mKeyPressed: Int(passcodeValue)!, isBackPressed: false)
                }

            }, label: {
                ZStack {
                    Image("passcodenumericbg")

                    if passcodeValue == "delete" {
                        Text("").foregroundColor(.white)
                        Image(systemName: "delete.left.fill").foregroundColor(.gray)
                    }else {
                        Text(passcodeValue).foregroundColor(.gray).bold().multilineTextAlignment(.center).font(
                            .barlowRegular(size: Device.isLarge ? 32 : 24)
                        )
                    }
                }.padding(2)
            })
    }
    
}

struct PasscodeNumpadRow: View {
    
    @Binding var startIndex : Int
    @Binding var endIndex : Int
    @Binding var passcodeViewModel: PasscodeViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            ForEach(startIndex ..< endIndex) { index in
                PasscodeNumber(passcodeValue: Binding.constant(String(index)),passcodeViewModel: $passcodeViewModel)
            }
        })
    }
}

struct PasscodeNumberView : View {
    @Binding var passcodeViewModel: PasscodeViewModel
    var body: some View {
        VStack {
            PasscodeNumpadRow(startIndex: Binding.constant(1), endIndex: Binding.constant(4),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeNumpadRow(startIndex: Binding.constant(4), endIndex: Binding.constant(7),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeNumpadRow(startIndex: Binding.constant(7), endIndex: Binding.constant(10),passcodeViewModel: Binding.constant(passcodeViewModel))
            HStack(alignment: .center, spacing: nil, content: {
                
                PasscodeNumber(passcodeValue: Binding.constant(""),passcodeViewModel: $passcodeViewModel).hidden()
                PasscodeNumber(passcodeValue: Binding.constant("0"),passcodeViewModel: $passcodeViewModel)
                PasscodeNumber(passcodeValue: Binding.constant("delete"),passcodeViewModel: $passcodeViewModel)
            })
        }
    }
}

struct PasscodeBackgroundView : View {
    var body: some View{
        Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color.zDarkGradient1, Color.zDarkGradient2]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.all)
    }
}

struct PasscodePinImageView: View {
    @Binding var isSelected:Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Image(isSelected ? "radioiconselected" : "radioiconunselected")
        }).frame(width: 40, height: 40, alignment: .center)
    }
}

struct PasscodeScreenTopImageView : View {
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Image("passcodeIcon").padding(.horizontal)
            Spacer()
        })
    }
}

struct PasscodeScreenTitle : View {
    @State var aTitle: String
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aTitle).foregroundColor(.gray).font(
                .barlowRegular(size: Device.isLarge ? 28 : 18)
            ).padding(.top,20)
            Spacer()
        })
    }
}

struct PasscodeScreenSubTitle : View {
    @State var aSubTitle: String
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aSubTitle).foregroundColor(.white).font(
                .barlowRegular(size: Device.isLarge ? 28 : 18)
            )
            Spacer()
        })
    }
}

struct PasscodeScreenDescription : View {
    @State var aDescription: String
    @State var size: CGFloat
    @State var padding:CGFloat
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aDescription).lineLimit(nil).foregroundColor(.white).font(
                .barlowRegular(size: size)
            ).padding(.leading,padding).padding(.trailing,padding).multilineTextAlignment(.center)
            Spacer()
        })
    }
}

//
//struct PasscodeScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PasscodeScreen()
//    }
//}


//struct PasscodeScreen: View {
//
//    @State var allowUserToMoveToHome = false
//
//    var body: some View {
//
//
//        NavigationLink(destination:
//            Home().environmentObject(HomeViewModel())
//            ,isActive: $allowUserToMoveToHome
//        ){
//
//            Button(action: {
//                allowUserToMoveToHome = true
//            }) {
//                Text("Open Home, WIP")
//            }
//
//
//        }
//
//    }
//}

struct PassCodeScreenDismiss {
    var isDismiss:Bool
}
