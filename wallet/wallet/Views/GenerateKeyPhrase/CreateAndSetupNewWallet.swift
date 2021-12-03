//
//  CreateWallet.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 02/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct CreateAndSetupNewWallet: View {
    @EnvironmentObject var viewModel: WordsVerificationViewModel
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment

    @State var openHomeScreen = false
    
    @State var error: UserFacingErrors?
    @State var showError: AlertType?
    @State var destination: Destinations?
    
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
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            NavigationLink(destination:
                            HomeTabView(openPasscodeScreen: false)
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
            , isActive: $openHomeScreen) {
                EmptyView()
            }
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                Text("Please wait, while we setup your wallet!".localized())
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .scaledFont(size: 15)
                
                LottieAnimation(isPlaying: true,
                                filename: "lottie_sending",
                                animationType: .circularLoop)
                    .frame(height: 48)
                Spacer()
            }
         
            
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear(){
            createNewWalletFlow()
        }
    }
    
    func createNewWalletFlow(){
        do {
            tracker.track(.tap(action: .landingBackupWallet), properties: [:])
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                openHomeScreen = true
            }
            try self.appEnvironment.createNewWalletWithPhrase(randomPhrase: self.viewModel.mCompletePhrase!.joined(separator: " "))
            
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
}

struct CreateAndSetupNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateAndSetupNewWallet()
    }
}
