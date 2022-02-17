//
//  SelectBackgroundMusic.swift
//  ECC-Wallet
//
//  Created by Lokesh on 17/02/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import SwiftUI
import AlertToast

class BackgroundSoundViewModel: ObservableObject {
    
    @Published var allBackgroundSounds = [CheckBoxRowData(id:0,title:"Temp",isSelected: true)]
    
    @Published var mSelectedIndex = 0
        
    var anArrayOfBackgroundSounds = ["Default Sound","Please Believe Sound","Notize Master Sound"]
     
    init() {
        createAndUpdateCheckBoxContentOfBirthdays()
        updateBirthdaySelectionStatus()
    }
    
    func createAndUpdateCheckBoxContentOfBirthdays(){
        
        allBackgroundSounds.removeAll()
        
        let mCurrentSelectionIndex = UserSettings.shared.mBackgroundSoundSelectionIndex
        
        for index in 0...anArrayOfBackgroundSounds.count-1 {
            if index == mCurrentSelectionIndex{
                mSelectedIndex = index
                allBackgroundSounds.append(CheckBoxRowData(id:index,title:anArrayOfBackgroundSounds[index],isSelected: true))
            }else{
                allBackgroundSounds.append(CheckBoxRowData(id:index,title:anArrayOfBackgroundSounds[index],isSelected: false))
            }
        }
    }
    
    func updateBirthdaySelectionStatus(){
        for var checkBoxData in allBackgroundSounds {
            if checkBoxData.id == mSelectedIndex {
                checkBoxData.isSelected = true
            }else{
                checkBoxData.isSelected = false
            }
        }
    }
    
    func getSelectedCheckboxObject()->CheckBoxRowData {
        return allBackgroundSounds[mSelectedIndex]
    }
    
}

struct SelectBackgroundMusic: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var backgroundSoundViewModel: BackgroundSoundViewModel = BackgroundSoundViewModel()
    
    @State var mSelectedSettingsRowData: CheckBoxRowData?
    
    @State var showUpdatedSoundFileToast = false
        
    @State var mCurrentSelectionIndex = UserSettings.shared.mBackgroundSoundSelectionIndex
       
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    var body: some View {
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                
                List {
                    
                    ForEach(backgroundSoundViewModel.allBackgroundSounds, id: \.id) { settingsRowData in
                        
                        RescanRowWithCheckbox(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:2, isSelected: settingsRowData.isSelected)
                            .onTapGesture {
                                self.mSelectedSettingsRowData = settingsRowData
                                self.backgroundSoundViewModel.mSelectedIndex = mSelectedSettingsRowData!.id
                                self.backgroundSoundViewModel.updateBirthdaySelectionStatus()
                                UserSettings.shared.mBackgroundSoundSelectionIndex = mSelectedSettingsRowData!.id
                            }
                            .frame(height: Device.isLarge ?  60 : 40)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                }
                .modifier(BackgroundPlaceholderModifierRescanOptions())
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.zGray, lineWidth: 1.0)
//                )
                .padding()
               
                
                Spacer(minLength: 50)
                
      
            }
            
            
        }.toast(isPresenting: $showUpdatedSoundFileToast){
            
            AlertToast(displayMode: .banner(.pop), type: .regular, title:"Updated the background sound.".localized())

        }
        
        .onAppear(perform: {
            
            mSelectedSettingsRowData = backgroundSoundViewModel.getSelectedCheckboxObject()
            
        })
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Select Background Music".localized()).navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack(alignment: .leading) {
                ZStack{
                    Image("backicon").resizable().frame(width: 50, height: 50)
                }
            }
        })
    }
}

struct SelectBackgroundMusic_Previews: PreviewProvider {
    static var previews: some View {
        SelectBackgroundMusic()
    }
}
