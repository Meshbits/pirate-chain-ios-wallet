//
//  NotificationScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 11/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct NotificationScreen: View {
    
    var generalSection = [SettingsRowData(id:0,title:"Push Notifications".localized()),
                          SettingsRowData(id:1,title:"Updates from us".localized())]
    
    @State var mSelectedSettingsRowData: SettingsRowData?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 10) {
                Spacer(minLength: 5)
                ScrollView {
                    VStack {
                        ForEach(generalSection, id: \.id) { settingsRowData in
                            NotificationsRowWithToggle(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:1)
                                .onTapGesture {
                                    self.mSelectedSettingsRowData = settingsRowData
                                }
                        }
                        
                    }
                    .modifier(SettingsSectionBackgroundModifier())
                    
                    
                }
            }
           
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Notifications".localized())
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
}

struct NotificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotificationScreen()
    }
}



struct NotificationsRowWithToggle: View {

    var mCurrentRowData:SettingsRowData
   
    @Binding var mSelectedSettingsRowData: SettingsRowData?
    
    @State var isToggleEnabled = true
    
    var noLineAfter = 0
    
    var body: some View {

        VStack {
            HStack{
                Text(mCurrentRowData.title).font(.barlowRegular(size: 16)).foregroundColor(Color.textTitleColor)
                                .frame(width: 200, height: 22,alignment: .leading)
                                .foregroundColor(Color.white)
                    .padding()
                
                
                Toggle("", isOn: $isToggleEnabled)
                    .onChange(of: isToggleEnabled, perform: { isEnabled in
                        
                        
                    })
                    .toggleStyle(ColoredToggleStyle()).labelsHidden()
            }
            
            if mCurrentRowData.id < noLineAfter {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            }
            
        }
    }
    
    func initiateLocalAuthenticationFlow(){
        if UserSettings.shared.biometricInAppStatus {
                       authenticate()
        }
    }
    
    func authenticate() {
         if UserSettings.shared.biometricInAppStatus {
             AuthenticationHelper.authenticate(with: "Authenticate Biometric".localized())
         }
     }
}
