//
//  IntroPrivacy.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 03/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct IntroPrivacy: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var isViewVisible = false
    @State var openPincodeScreen = false
    let mAnimationDuration = 1.5
    var body: some View {
//         NavigationView
//         {
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                
                        VStack(alignment: .center, content: {
                            Text("Privacy! \n not Piracy".localized()).lineLimit(nil).fixedSize(horizontal: false, vertical: true).padding(.trailing,80).padding(.leading,80).foregroundColor(.white).multilineTextAlignment(.center)
                                .scaledFont(size: 26)
                            Text("Reliable, Fast & Secure".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray)
                                .scaledFont(size: 14)
                            ZStack{
                                Image("backgroundglow")
                                    .padding(.trailing,80).padding(.leading,80)
                                
                                HStack(alignment: .center, spacing: -30, content: {

                                    withAnimation(Animation.linear(duration: mAnimationDuration).repeatForever(autoreverses: true)){
                                        Image("skullcoin")
                                            .offset(y: isViewVisible ? 40:0)
                                            .animation(Animation.linear(duration: mAnimationDuration).repeatForever(autoreverses: true), value: isViewVisible)
                                    }
                                    
                                    Image("coin").padding(.top,50)
                                        .rotationEffect(Angle(degrees: isViewVisible ? -40 : 0))
//                                        .transition(.move(edge: .top))
                                        .animation(Animation.linear(duration: mAnimationDuration).repeatForever(autoreverses: true), value: isViewVisible)
                                        .onAppear {
                                        withAnimation(.linear){
                                            DispatchQueue.main.asyncAfter(deadline:.now()+0.5){
                                                isViewVisible = true
                                            }
                                        }
                                    }

                                })
                            }
                            
                            
                            NavigationLink(
                                
                                destination: LazyView(PasscodeView(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode, isNewWallet: true,isAllowedToPop:true)).environmentObject(self.appEnvironment),
                                           isActive: $openPincodeScreen
                            ) {
                                Button(action: {
                                    openPincodeScreen = true
                                }) {
                                    BlueButtonView(aTitle: "Continue".localized())
                                }
                                .padding(.bottom,20)
                            }
                        })
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.all)
                    
                    }.zcashNavigationBar(leadingItem: {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("backicon").resizable().frame(width: 60, height: 60).padding(.leading,40).padding(.top,20)
                        }

                    }, headerItem: {
                        EmptyView()
                    }, trailingItem: {
                        EmptyView()
                    })

//         }.navigationBarHidden(true)
        
    }
}

struct IntroPrivacy_Previews: PreviewProvider {
    static var previews: some View {
        IntroPrivacy()
    }
}
