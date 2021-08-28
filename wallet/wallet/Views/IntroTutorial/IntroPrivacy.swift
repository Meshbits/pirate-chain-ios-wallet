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
    @State var openPincodeScreem = false
    var body: some View {
         NavigationView
         {
            ZStack{
                ARRRBackground()
                
                        VStack(alignment: .center, content: {
                            Text("Privacy! \nnot Piracy").padding(.trailing,120).padding(.leading,120).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                            Text("Reliable, fast & Secure").padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 16 : 10))
                            ZStack{
                                Image("backgroundglow")
                                    .padding(.trailing,80).padding(.leading,80)
                                
                                HStack(alignment: .center, spacing: -30, content: {

                                    withAnimation(Animation.linear(duration: 2).delay(1).repeatForever(autoreverses: true)){
                                        Image("skullcoin")
                                            .offset(y: isViewVisible ? 40:0)
                                            .animation(Animation.linear(duration: 2).delay(1).repeatForever(autoreverses: true), value: isViewVisible)
                                    }
                                    
                                    Image("coin").padding(.top,50)
                                        .rotationEffect(Angle(degrees: isViewVisible ? -40 : 0))
//                                        .transition(.move(edge: .top))
                                        .animation(Animation.linear(duration: 2).delay(1).repeatForever(autoreverses: true), value: isViewVisible)
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
                                
                                destination: LazyView(PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode, isNewWallet: true)).environmentObject(self.appEnvironment),
                                           isActive: $openPincodeScreem
                            ) {
                                Button(action: {
                                    openPincodeScreem = true
                                }) {
                                    BlueButtonView(aTitle: "Continue")
                                }
                            }
                        })

                    }.edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("passcodenumericbg")
                            Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
                        }
                    }.padding(.leading,-20).padding(.top,10)
                })
         }.navigationBarHidden(true)
        
    }
}

struct IntroPrivacy_Previews: PreviewProvider {
    static var previews: some View {
        IntroPrivacy()
    }
}
