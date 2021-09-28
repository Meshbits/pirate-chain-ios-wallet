//
//  IntroWelcome.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 31/07/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct IntroWelcome: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var isViewVisible = false
    @State var openNextIntroScreen = false
    var body: some View {
//         NavigationView
//         {
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                
                        VStack(alignment: .center, content: {
                            Text("Welcome to Pirate Wallet".localized()).padding(.trailing,120).padding(.leading,120).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                                .scaledFont(size: 30)
                                .padding(.top,80)
                            Text("Reliable, fast & Secure".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                                .scaledFont(size: 14)
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
                                destination: IntroPrivacy().environmentObject(self.appEnvironment),
                                           isActive: $openNextIntroScreen
                            ) {
                                Button(action: {
                                    openNextIntroScreen = true
                                }) {
                                    BlueButtonView(aTitle: "Get Started".localized())
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
//         }.navigationBarHidden(true)
        
    }
}

struct IntroWelcome_Previews: PreviewProvider {
    static var previews: some View {
        IntroWelcome()
    }
}
