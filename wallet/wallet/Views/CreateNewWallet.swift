//
//  CreateNewWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Neumorphic

struct CreateNewWallet: View {
    
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
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var error: UserFacingErrors?
    @State var showError: AlertType?
    @State var destination: Destinations?
    let itemSpacing: CGFloat = 2
    let buttonPadding: CGFloat = 10
    let buttonHeight: CGFloat = 50
    @State var openCreateNewWalletFlow = false
    var body: some View {

        ZStack {
            NavigationLink(destination:
                LazyView (
                    BackupWallet().environmentObject(self.appEnvironment)
                    .navigationBarHidden(true)
                ),
                           tag: Destinations.createNew,
                           selection: $destination
                
            ) {
              EmptyView()
            }
            ARRRBackground()
            
            VStack(alignment: .center, spacing: self.itemSpacing) {
                Spacer()
                
                ARRRLogo(fillStyle: LinearGradient.amberGradient).padding(.leading,20)
                
                Spacer()

//                Text("Restore from".localized()).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading,30).scaledFont(size: 14)

                VStack(alignment: .center, spacing: 10.0, content: {
                    
//                    ZStack {
//                        RecoveryWalletButtonView(imageName: Binding.constant("buttonbackground"), title: Binding.constant("iCloud Backup".localized()))
//                    }.frame(width: 225.0, height:84).hidden()
//
                    NavigationLink(
                        destination: RestorePhraseScreen().environmentObject(self.appEnvironment)/*RestoreWallet()
                                        .environmentObject(self.appEnvironment)*/,
                                   tag: Destinations.restoreWallet,
                                   selection: $destination
                            
                    ) {
                        Button(action: {
                            guard !ZECCWalletEnvironment.shared.credentialsAlreadyPresent() else {
                                self.showError = .feedback(destination: .restoreWallet, cause: SeedManager.SeedManagerError.alreadyImported)
                                return
                            }
                            self.destination = .restoreWallet
                        }) {
                            RecoveryWalletButtonView(imageName: Binding.constant("buttonbackground"), title: Binding.constant("Restore Wallet".localized()))
                        }
                    }
                   
                    
                })
                .modifier(BackgroundPlaceholderModifierRecoveryOptions())
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zSlightLightGray, lineWidth: 2.0)
                )
                .padding(20)
                
                Color.black.frame(height:CGFloat(1) / UIScreen.main.scale).frame(height:2).padding(.leading,15).padding(.trailing,15)
  
                NavigationLink(
                    destination: IntroWelcome().environmentObject(self.appEnvironment),
                               isActive: $openCreateNewWalletFlow
                        
                ) {
                    Button(action: {
//                      createNewWalletFlow()
                        openCreateNewWalletFlow = true
                    }) {
                        BlueButtonView(aTitle: "Create New Wallet".localized())
                    }
                }
                
//                #if DEBUG
//                Button(action: {
//                    self.appEnvironment.nuke()
//                }) {
//                    Text("NUKE WALLET".localized())
//                        .foregroundColor(.red)
//                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
//                        .frame(height: self.buttonHeight)
//
//                }
//                #endif
               
            }
            .padding([.horizontal, .bottom], self.buttonPadding)
        }
        .onAppear {
            tracker.track(.screen(screen: .landing), properties: [ : ])
        }
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
    
    func createNewWalletFlow(){
        do {
            tracker.track(.tap(action: .landingBackupWallet), properties: [:])
            try self.appEnvironment.createNewWallet()
            self.destination = Destinations.createNew
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

struct CreateNewWallet_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewWallet()
            .colorScheme(.dark)
    }
}


struct BackgroundPlaceholderModifierRecoveryOptions: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 32.0/255.0, green: 35.0/255.0, blue: 39.0/255.0)))
    }
}


extension CreateNewWallet.Destinations: Hashable {}


struct BlueButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bluebuttonbackground").resizable().fixedSize().frame(width: 225.0, height:84).padding(.top,5)
            
            if #available(iOS 15.0, *) {
                Text(aTitle).foregroundColor(Color.black)
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
                    .cornerRadius(15)
                    .dynamicTypeSize(.medium)
                    .scaledFont(size: Device.isLarge ? 19 : 13)
                    .multilineTextAlignment(.center)
            } else {
                // Fallback on earlier versions
                Text(aTitle).foregroundColor(Color.black)
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
                    .cornerRadius(15)
                    .modifier(BarlowModifier(.footnote))
                    .multilineTextAlignment(.center)
            }
        }.frame(width: Device.isLarge ? 225.0 : 130.0, height:Device.isLarge ? 84 : 60)
        
    }
}

struct GrayButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("buttonbackground").resizable().fixedSize().frame(width: 225.0, height:84).padding(.top,5)
            
            if #available(iOS 15.0, *) {
                Text(aTitle).foregroundColor(Color.zARRRTextColorLightYellow).bold()
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
                    .cornerRadius(15)
                    .scaledFont(size: Device.isLarge ? 19 : 13)
                    .dynamicTypeSize(.medium)
                    .multilineTextAlignment(.center)
            } else {
                // Fallback on earlier versions
                Text(aTitle).foregroundColor(Color.zARRRTextColorLightYellow).bold()
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
                    .cornerRadius(15)
                    .modifier(BarlowModifier(.footnote))
                    .multilineTextAlignment(.center)
            }
        }.frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
        
    }
}


struct RecoveryWalletButtonView : View {
    
    @Binding var imageName: String
    @Binding var title: String
    
    var body: some View {
        ZStack {

            Image(imageName).resizable().fixedSize().frame(width: 225.0, height:84).padding(.top,5)
            
            if #available(iOS 15.0, *) {
                Text(title).foregroundColor(Color.zARRRTextColorLightYellow)
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60).padding(10)
                    .cornerRadius(15)
                    .dynamicTypeSize(.medium)
                    .scaledFont(size: Device.isLarge ? 19 : 13)
                    .multilineTextAlignment(.center)
            } else {
                Text(title).foregroundColor(Color.zARRRTextColorLightYellow)
                    .frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60).padding(10)
                    .cornerRadius(15)
                    .modifier(BarlowModifier(.footnote))
                    .multilineTextAlignment(.center)
                
            }
        }.frame(width: Device.isLarge ? 225.0 : 150.0, height:Device.isLarge ? 84 : 60)
    }
}
