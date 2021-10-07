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
    let mAnimationDuration = 1.5
    var body: some View {
//         NavigationView
//         {
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                
                        VStack(alignment: .center, content: {
                            Text("Welcome to Pirate Wallet".localized()).lineLimit(nil).fixedSize(horizontal: false, vertical: true).padding(.trailing,120).padding(.leading,120).foregroundColor(.white).multilineTextAlignment(.center)
                                .scaledFont(size: 26)
                            Text("Reliable, fast & Secure".localized()).padding(.trailing,80).padding(.leading,80).multilineTextAlignment(.center).foregroundColor(.gray)
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
//                                            DispatchQueue.main.asyncAfter(deadline:.now()+0.5){
                                                isViewVisible = true
//                                            }
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
                                }.padding(.bottom,20)
                            }
                            
                            
                        })
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.all)
                    .zcashNavigationBar(leadingItem: {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            ZStack{
                               Image("passcodenumericbg")
                               Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).padding([.bottom],8).foregroundColor(Color.init(red: 233/255, green: 233/255, blue: 233/255))
                            }.padding(.leading,40)
                        }

                    }, headerItem: {
                        EmptyView()
                    }, trailingItem: {
                        EmptyView()
                    })

                    }

        
                       
//         }.navigationBarHidden(true)
        
    }
}

struct IntroWelcome_Previews: PreviewProvider {
    static var previews: some View {
        IntroWelcome()
    }
}
