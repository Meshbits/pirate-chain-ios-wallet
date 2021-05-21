//
//  ProfileScreen.swift
//  wallet
//
//  Created by Francisco Gindre on 1/22/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct ProfileScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var nukePressed = false
    @Environment(\.presentationMode) var presentationMode
    static let buttonHeight = CGFloat(48)
    static let horizontalPadding = CGFloat(30)
    @State var copiedValue: PasteboardItemModel?
    @Binding var isShown: Bool
    @State var alertItem: AlertItem?
    @State var shareItem: ShareItem? = nil
    @State var isFeedbackActive = false
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                
                ZcashBackground.pureBlack
             
                VStack(alignment: .center, spacing: 16) {
                    Button(action: {
                        tracker.track(.tap(action: .copyAddress),
                                      properties: [:])
                        PasteboardAlertHelper.shared.copyToPasteBoard(value: self.appEnvironment.initializer.getAddress() ?? "", notify: "Address Copied to clipboard!")
                        
                    }) {
                        Text("My Zcash Address\n".localized() + (appEnvironment.initializer.getAddress()?.shortZaddress ?? ""))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .onReceive(PasteboardAlertHelper.shared.publisher) { (item) in
                        self.copiedValue = item
                    }
                    .padding(0)
                    
                    Button(action: {
                        let url = URL(string: "https://sideshift.ai/a/EqcQp4iUM")!

                        UIApplication.shared.open(url)}) {
                            Text("Fund my wallet via SideShift.ai")
                                .foregroundColor(.black)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                                .frame(height: Self.buttonHeight)
                    }
                    
                    Button(action: {
                        let url = URL(string: "https://twitter.com/nighthawkwallet")!
                        
                        UIApplication.shared.open(url)}) {
                            Text("@nighthawkwallet")
                                .foregroundColor(.black)
                                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                                .frame(height: Self.buttonHeight)
                    }
                    
                    NavigationLink(destination: LazyView(
                        SeedBackup(hideNavBar: false)
                            .environmentObject(self.appEnvironment)
                        )
                    ) {
                        Text("button_backup")
                            .foregroundColor(.white)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .white, lineWidth: 1)))
                            .frame(height: Self.buttonHeight)
                        
                    }
                    
                    NavigationLink(destination: LazyView(
                        InputPasscodeWithCustomPad().environmentObject(ZECCWalletEnvironment.shared))
                    ) {
                                    
                        Text("My Profile".localized())
                            .foregroundColor(.zYellow)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .zYellow, lineWidth: 1)))
                            .frame(height:  Self.buttonHeight)
                    }
                    
                    
                    ActionableMessage(message: "\("Nighthawk Wallet".localized()) v\(ZECCWalletEnvironment.appVersion ?? "Unknown")", actionText: "Build \(ZECCWalletEnvironment.appBuild ?? "Unknown")", action: {})
                        .disabled(true)
                    
                    NavigationLink(destination: LazyView (
                        NukeWarning().environmentObject(self.appEnvironment)
                    ), isActive: self.$nukePressed) {
                        EmptyView()
                    }.isDetailLink(false)
                    
                    Button(action: {
                        tracker.track(.tap(action: .profileNuke), properties: [:])
                        self.nukePressed = true
                    }) {
                        Text("DELETE WALLET".localized())
                            .foregroundColor(.red)
                            .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 1)))
                            .frame(height: Self.buttonHeight)
                    }
                }.padding(.horizontal, Self.horizontalPadding)
                .padding(.bottom, 30)
            }
            
            .alert(item: self.$copiedValue) { (p) -> Alert in
                PasteboardAlertHelper.alert(for: p)
            }
            .sheet(item: self.$shareItem, content: { item in
                ShareSheet(activityItems: [item.activityItem])
            })
            .alert(item: self.$alertItem, content: { a in
                a.asAlert()
            })
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                tracker.track(.tap(action: .profileClose), properties: [:])
                self.isShown = false
            }).frame(width: 30, height: 30))
        }
        .background(Color.black)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .navigationBarItems(trailing: ZcashCloseButton(action: {
            tracker.track(.tap(action: .profileClose), properties: [:])
            self.isShown = false
        }).frame(width: 30, height: 30))
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(isShown: .constant(true)).environmentObject(ZECCWalletEnvironment.shared)
    }
}
