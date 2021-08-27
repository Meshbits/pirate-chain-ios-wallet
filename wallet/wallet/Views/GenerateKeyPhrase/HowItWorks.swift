//
//  HowItWorks.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 27/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class HowItWorksViewModel: ObservableObject {
    
    @Published var mScreenTitle = "How it works - Step 1"
    @Published var mDescriptionTitle = "Write down your key"
    @Published var mDescriptionSubTitle = "Write down your key on paper and confirm it. Screenshots are not recommended for security reasons."
    
    @Published var destination: ScreenSteps = ScreenSteps.step_one
        
    enum ScreenSteps: Int {
        case step_one
        case step_two
        case step_three
        case move_next
        
        
        var id: Int {
            switch self {
            case .step_one:
                return 0
            case .step_two:
                return 1
            case .step_three:
                return 2
            case .move_next:
                return 3
            }
        }
        
        mutating func next(){
              self = ScreenSteps(rawValue: rawValue + 1) ?? ScreenSteps(rawValue: 0)!
        }
    }
    
    
    func updateLayoutTextOrMoveToNextScreen(){
        
        destination.next()
        
        switch (destination) {
        case .step_one:
            mScreenTitle = "How it works - Step 1"
            mDescriptionTitle = "Write down your key"
            mDescriptionSubTitle = "Write down your key on paper and confirm it. Screenshots are not recommended for security reasons."
            break
        case .step_two:
            mScreenTitle = "How it works - Step 2"
            mDescriptionTitle = "Keep it secure"
            mDescriptionSubTitle = "Store your key in a secure location. This is the only way to recover your wallet. Pirate Wallet does not keep a copy."
            break
        case .step_three:
            mScreenTitle = "How it works - Step 3"
            mDescriptionTitle = "Store, send or receive"
            mDescriptionSubTitle = "Store, send or receive knowing that your funds are protected by the best security and privacy in the business"
            break
        case .move_next:
            mScreenTitle = "Move To next screen - recovery phrase"
            mDescriptionTitle = "Move To next screen - recovery phrase"
            mDescriptionSubTitle = "Move To next screen - recovery phrase."
            break
        }
        
    }
    
}

struct HowItWorks: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: HowItWorksViewModel
  
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, content: {
                Text(self.viewModel.mDescriptionTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text(self.viewModel.mDescriptionSubTitle).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                Spacer()
                
                Button {
                    self.viewModel.updateLayoutTextOrMoveToNextScreen()
                } label: {
                    BlueButtonView(aTitle: "Continue")
                }

            })
            
        }.zcashNavigationBar(leadingItem: {
            ARRRBackButton(action: {
                presentationMode.wrappedValue.dismiss()
                }).frame(width: 30, height: 30)
         }, headerItem: {
             HStack{
                Text(self.viewModel.mScreenTitle)
                     .font(.barlowRegular(size: 18)).foregroundColor(Color.zSettingsSectionHeader)
                     .frame(alignment: Alignment.center)
             }
         }, trailingItem: {
             EmptyView()
         })        
    }
    
}

struct HowItWorks_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks()
    }
}
