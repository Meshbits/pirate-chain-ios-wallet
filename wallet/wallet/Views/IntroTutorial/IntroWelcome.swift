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
    
    @State var mMoveToPincode = false
    
    @State var mMoveToPrivacy = false
    
    @State var mTitle = "Welcome to \nPirate Wallet".localized()
    
    @State var mSubTitle = "Reliable, fast & Secure".localized()
    
    @State var mButtonTitle =  "Get Started".localized()
    
    func moveNext(){
        if !mMoveToPrivacy {
            mTitle = "Privacy! \n not Piracy".localized()
            mButtonTitle = "Continue".localized()
            mMoveToPrivacy = true
        }else if !mMoveToPincode {
            mMoveToPincode = true
        }
    }
    
    func moveBack(){
        
        if mMoveToPrivacy {
            mTitle = "Welcome to \nPirate Wallet".localized()
            mButtonTitle = "Get Started".localized()
            mMoveToPincode = false
            mMoveToPrivacy = false
        }
        
    }
    
    let mAnimationDuration = 1.5
        
    var body: some View {
//         NavigationView
//         {
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                
                        VStack(alignment: .center, content: {
                            
                            Spacer()
                            
                            Text(mTitle.localized()).transition(.move(edge: .trailing)).id("MyTitleComponent1" + mTitle).lineLimit(nil).fixedSize(horizontal: false, vertical: true).padding(.trailing,120).padding(.leading,120).foregroundColor(.white).multilineTextAlignment(.center)
                                .scaledFont(size: 26).padding(.top,40)
                            Text(mSubTitle.localized()).padding(.trailing,80).padding(.leading,80).multilineTextAlignment(.center).foregroundColor(.gray)
                                .scaledFont(size: 16)
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
                                
                                destination: LazyView(PasscodeView(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode, isNewWallet: true,isAllowedToPop:true)).environmentObject(self.appEnvironment),
                                           isActive: $mMoveToPincode
                            ) {
                                Button(action: {
                                    withAnimation(.easeIn(duration: 0.5), {
                                        moveNext()
                                   })
                                    
                                }) {
                                    ZStack {
                                        
                                        Image("bluebuttonbackground").resizable().fixedSize().frame(width: 225.0, height:84).padding(.top,5)
                                        
                                        Text(mButtonTitle).foregroundColor(Color.black)
                                            .frame(width: 225.0, height:84)
                                            .cornerRadius(15)
                                            .scaledFont(size: 19)
                                            .multilineTextAlignment(.center)
                                    }.frame(width: 225.0, height:84)
                                    
                                }
                                .padding(.bottom,20)
                            }
                            
                        })
                    .edgesIgnoringSafeArea(.all)
                  

                    }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:  Button(action: {
                if !mMoveToPincode && !mMoveToPrivacy {
                    presentationMode.wrappedValue.dismiss()
                }else{
                    withAnimation(.easeIn(duration: 0.5), {
                        moveBack()
                   })
                }
                
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("backicon").resizable().frame(width: 50, height: 50)
                    }
                }
            })
        
                       
//         }.navigationBarHidden(true)
        
    }
}

struct IntroWelcome_Previews: PreviewProvider {
    static var previews: some View {
        IntroWelcome()
    }
}
