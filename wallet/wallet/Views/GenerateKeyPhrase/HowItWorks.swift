//
//  HowItWorks.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 27/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class HowItWorksViewModel: ObservableObject {
    
    @State var mScreenTitle = "How it works - Step 1"
    @State var mDescriptionTitle = "Write down your key"
    @State var mDescriptionSubTitle = "Write down your key on paper and confirm it. Screenshots are not recommended for security reasons."
        
    enum Steps: Int {
        case step_one
        case step_two
        case step_three
        case move_next
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
