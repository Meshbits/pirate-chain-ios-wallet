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
    @State var showListOfBirthdays = false
    var anArrayOfBirthdays = [1910000,1900000,1890000,1880000,1870000,1860000,1850000,1840000,1830000,
                              1820000,1810000,1800000,1790000,1780000,1640000,1630000,1620000,1610000,1600000,
                              1590000,1580000,1570000,1560000,1550000,1540000,1530000,1520000,1510000,1500000,
                              1490000,1480000,1470000,1460000,1450000,1440000,1430000,1420000,1410000,1400000,
                              1390000,1380000,1370000,1360000,1350000,1340000,1330000,1320000,1310000,1300000,
                              1290000,1280000,1270000,1260000,1250000,1240000,1230000,1220000,1210000,1200000,
                              1190000,1180000,1170000,1160000,1150000,1140000,1130000,1120000,1110000,1100000,
                              1090000,1080000,1070000,1060000,1050000,1040000,1030000,1020000,1010000,1000000,
                               900000,800000,700000,600000,500000,400000,300000,200000]
    
    var seedPhraseSubtitle: some View {
        if seedPhrase.isEmpty {
            return Text.subtitle(text: "Make sure nobody is watching you!".localized()).font(.barlowRegular(size: Device.isLarge ? 15 : 10))
        }
        
        do {
           try MnemonicSeedProvider.default.isValid(mnemonic: seedPhrase)
            return Text.subtitle(text: "Your seed phrase is valid".localized()).font(.barlowRegular(size: Device.isLarge ? 15 : 10))
        } catch {
            return Text.subtitle(text: "Your seed phrase is invalid!".localized()).font(.barlowRegular(size: Device.isLarge ? 15 : 10))
                .foregroundColor(.red)
                .bold()
        }
    }
    
    var centerBody: some View {
            ZStack {
                             
                VStack(spacing: 40) {
                    
                    ZcashTextField(
                        title: "Enter Your Seed Phrase".localized(),
                        subtitleView: AnyView(
                            seedPhraseSubtitle
                        ),
                        keyboardType: UIKeyboardType.alphabet,
                        binding: $seedPhrase,
                        onEditingChanged: { _ in },
                        onCommit: {}
                    ).scaledFont(size: 17)
                    .multilineTextAlignment(.leading).padding(.top,100)
                  
                    HStack{
                        ZcashTextField(
                            title: "Wallet Birthday Height".localized(),
                            subtitleView: AnyView(
                                Text.subtitle(text: "If you don't know, leave it blank. First sync will take longer with default birthday height to be 1390000.".localized())
                                    .scaledFont(size: Device.isLarge ? 15 : 10)
                            ),
                            keyboardType: UIKeyboardType.decimalPad,
                            binding: $walletBirthDay,
                            onEditingChanged: { _ in },
                            onCommit: {}
                        ).scaledFont(size: 17)
                        .multilineTextAlignment(.leading)
                        
                        Button {
                            self.showListOfBirthdays = true
                        } label: {
                            Image(systemName: "chevron.down.circle.fill").foregroundColor(.gray)
                                .scaledFont(size: Device.isLarge ? 30 : 20).foregroundColor(.gray)
                                .padding(.bottom, 5)
                        }

                    }
                    Button(action: {
                        
                    Task { @MainActor in
                           do {
                               try self.importSeed()
                               try self.importBirthday()
                               try await self.appEnvironment.initialize()
                           } catch {
                               logger.error("\(error)")
                               tracker.track(.error(severity: .critical), properties: [
                                   ErrorSeverity.underlyingError : "\(error)"])
                               self.showError = true
                               return
                           }
                           tracker.track(.tap(action: .walletImport), properties: [:])
                           self.proceed = true
                    }
                        
                    }) {
                        BlueButtonView(aTitle: "Proceed".localized())
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
                Alert(title: Text("Could not restore wallet".localized()),
                      message: Text("There's a problem restoring your wallet. Please verify your seed phrase and try again.".localized()),
                      dismissButton: .default(Text("button_close".localized())))
            }
            .onAppear {
                tracker.track(.screen(screen: .restore), properties: [:])
            }.actionSheet(isPresented: self.$showListOfBirthdays, content: {
                self.showBirthdayOptions()
            })
    }
    
    func showBirthdayOptions() -> ActionSheet {
        return ActionSheet(title: Text("\nChoose a birthday height for sync, leave it default if you are not sure.\n".localized()).foregroundColor(.white), buttons:
                            anArrayOfBirthdays.map { size in
                .default(Text(String.init(format: "%d", size)).foregroundColor(.gray)) { self.walletBirthDay = String.init(format: "%d", size) }
        } + [Alert.Button.cancel()]
        )
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
                                        PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode,isFirstTimeSetup: true)
                ), isActive: $proceed) {
                    EmptyView()
                }
                                  
            }.edgesIgnoringSafeArea(.all)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
//        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Recovery Phrase".localized())
            .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:   Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image("backicon").resizable().frame(width: Device.isLarge ? 60 : 45, height: Device.isLarge ? 60 : 45)
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
        
        return b >= ZCASH_NETWORK.constants.saplingActivationHeight
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
        let b = BlockHeight(self.walletBirthDay.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ZCASH_NETWORK.constants.saplingActivationHeight
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
