//
//  RestorePhraseScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 31/07/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

struct RestorePhraseScreen: View {
    
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var seedPhrase: String = ""
    @State var walletBirthDay: String = ""
    @State var showError = false
    @State var proceed: Bool = false
    
    var seedPhraseSubtitle: some View {
        if seedPhrase.isEmpty {
            return Text.subtitle(text: "Make sure nobody is watching you!".localized()).font(.barlowRegular(size: Device.isLarge ? 18 : 12))
        }
        
        do {
           try MnemonicSeedProvider.default.isValid(mnemonic: seedPhrase)
           return Text.subtitle(text: "Your seed phrase is valid").font(.barlowRegular(size: Device.isLarge ? 18 : 12))
        } catch {
            return Text.subtitle(text: "Your seed phrase is invalid!").font(.barlowRegular(size: Device.isLarge ? 18 : 12))
                .foregroundColor(.red)
                .bold()
        }
    }
    
    var centerBody: some View {
            ZStack {
                             
                VStack(spacing: 40) {
                    
                    ZcashTextField(
                        title: "Enter your Seed Phrase".localized(),
                        subtitleView: AnyView(
                            seedPhraseSubtitle
                        ),
                        keyboardType: UIKeyboardType.alphabet,
                        binding: $seedPhrase,
                        onEditingChanged: { _ in },
                        onCommit: {}
                    ).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                    .multilineTextAlignment(.leading).padding(.top,100)
                    
                    ZcashTextField(
                        title: "Wallet Birthday height".localized(),
                        subtitleView: AnyView(
                            Text.subtitle(text: "If you don't know it, leave it blank. First Sync will take longer.".localized()).font(.barlowRegular(size: Device.isLarge ? 18 : 12))
                        ),
                        keyboardType: UIKeyboardType.decimalPad,
                        binding: $walletBirthDay,
                        onEditingChanged: { _ in },
                        onCommit: {}
                    ).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                    .multilineTextAlignment(.leading)
                    
                    Button(action: {
                        do {
                            try self.importSeed()
                            try self.importBirthday()
                            try self.appEnvironment.initialize()
                        } catch {
                            logger.error("\(error)")
                            tracker.track(.error(severity: .critical), properties: [
                                ErrorSeverity.underlyingError : "\(error)"])
                            self.showError = true
                            return
                        }
                        tracker.track(.tap(action: .walletImport), properties: [:])
                        self.proceed = true
                    }) {
                        BlueButtonView(aTitle: "Proceed")
                    }
                    .disabled(disableProceed)
                    .opacity(disableProceed ? 0.4 : 1.0)
                    .frame(height: 58)
                    
                    Spacer()
                }
                .padding([.horizontal,.top, .bottom], 30)
            }.onTapGesture {
                UIApplication.shared.endEditing()
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Could not restore wallet"),
                      message: Text("There's a problem restoring your wallet. Please verify your seed phrase and try again."),
                      dismissButton: .default(Text("button_close")))
            }
            .onAppear {
                tracker.track(.screen(screen: .restore), properties: [:])
            }

    }
    
    init() {
            UINavigationBar.appearance().titleTextAttributes = [.font : Font.custom("Barlow-Regular", size: Device.isLarge ? 26 : 18)]
    }
    
    var body: some View {
//        NavigationView {
            ZStack{
                ARRRBackground()
               
                VStack(alignment: .center) {
                    centerBody
                }
                NavigationLink(destination:
                                LazyView(
                                        PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode)
                ), isActive: $proceed) {
                    EmptyView()
                }
                  
                
            }.edgesIgnoringSafeArea(.all)
//        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
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
    
    var isValidBirthday: Bool {
        validateBirthday(walletBirthDay)
    }
    
    var isValidSeed: Bool {
        validateSeed(seedPhrase)
    }
    
    func validateBirthday(_ birthday: String) -> Bool {
        
        guard !birthday.isEmpty else {
            return true
        }
        
        guard let b = BlockHeight(birthday) else {
            return false
        }
        
        return b >= ZcashSDK.SAPLING_ACTIVATION_HEIGHT
    }
    
    func validateSeed(_ seed: String) -> Bool {
        do {
            try MnemonicSeedProvider.default.isValid(mnemonic: seed)
            return true
        } catch {
            return false
        }
    }
    
    func importBirthday() throws {
        let b = BlockHeight(self.walletBirthDay.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ZcashSDK.SAPLING_ACTIVATION_HEIGHT
        try SeedManager.default.importBirthday(b)
    }
    
    func importSeed() throws {
        let trimmedSeedPhrase = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSeedPhrase.isEmpty else {
            throw WalletError.createFailed(underlying: MnemonicError.invalidSeed)
        }
        
        try SeedManager.default.importPhrase(bip39: trimmedSeedPhrase)
    }
    
    var disableProceed: Bool {
        !isValidSeed || !isValidBirthday
    }
}

struct RestorePhraseScreen_Previews: PreviewProvider {
    static var previews: some View {
        RestorePhraseScreen()
    }
}
