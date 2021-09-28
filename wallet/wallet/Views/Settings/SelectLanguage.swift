//
//  SelectLanguage.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 14/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct CheckBoxRowData : Equatable {
    var id: Int
    var title: String
    var isSelected: Bool
}



class SelectLanguageViewModel: ObservableObject {
    
    @Published var allLanguages = [CheckBoxRowData(id:0,title:"English",isSelected: true),
                        CheckBoxRowData(id:1,title:"Spanish  (Español)",isSelected: false),
                        CheckBoxRowData(id:2,title:"Russian  (pусский)",isSelected: false)]
    
    init() {
        updateLanguagesStatus()
    }
    
    func updateLanguagesStatus(){
        for var checkBoxData in allLanguages {
            if checkBoxData.id == UserSettings.shared.languageSelectionIndex {
                checkBoxData.isSelected = true
            }else{
                checkBoxData.isSelected = false
            }
        }
    }
    
    func updateAllLanguagesLayoutAfterChange(){

        allLanguages.removeAll()
        
        let aTitles = ["English", "Spanish  (Español)","Russian  (pусский)"]
        
        for index in 0...2 {
            if index == UserSettings.shared.languageSelectionIndex {
                allLanguages.append(CheckBoxRowData(id:index,title:aTitles[index],isSelected: true))
            }else{
                allLanguages.append(CheckBoxRowData(id:index,title:aTitles[index],isSelected: false))
            }
        }
        
    }
}


struct SelectLanguage: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var languageViewModel: SelectLanguageViewModel = SelectLanguageViewModel()
    
    @State var mSelectedSettingsRowData: CheckBoxRowData?
    
    var body: some View {
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 10) {
                Spacer(minLength: 5)
                
                Text("Select Language".localized()).frame(height:40).scaledFont(size: 20).multilineTextAlignment(.center).foregroundColor(Color.zSettingsSectionHeader)
                    
                ScrollView {

                    VStack {
                        ForEach(languageViewModel.allLanguages, id: \.id) { settingsRowData in
                            
                            SettingsRowWithCheckbox(mCurrentRowData: settingsRowData, mSelectedCheckBoxRowData: $mSelectedSettingsRowData, noLineAfter:2, isSelected: settingsRowData.isSelected)
                                .onTapGesture {
                                    self.mSelectedSettingsRowData = settingsRowData
                                    changeLanguage()
                                    self.languageViewModel.updateLanguagesStatus()
                            }
                        }
                        
                    }
                    .modifier(SettingsSectionBackgroundModifier())
                    
                    Spacer(minLength: 50)
                    
                    Button {
                        dismissBottomSheet()
                    } label: {
                        BlueButtonView(aTitle: "Cancel".localized())
                    }

                }
                .background(Color.screenBgColor)
      
            }
        }
    }
    
    func changeLanguage(){

        switch(mSelectedSettingsRowData?.id){
            case 0:
                updateLanguageAndResetApp(language: "en")
            break
            case 1:
                updateLanguageAndResetApp(language: "es")
            break
            case 2:
                updateLanguageAndResetApp(language: "ru")
            break

            default:
            print("None")
        }
        
        UserSettings.shared.languageSelectionIndex = mSelectedSettingsRowData?.id ?? 0
        
        dismissBottomSheet()

    }
    
    func dismissBottomSheet(){
        languageViewModel.updateAllLanguagesLayoutAfterChange()
        NotificationCenter.default.post(name: NSNotification.Name("DismissSettings"), object: nil)
    }
    
    func updateLanguageAndResetApp(language: String){
          Bundle.setLanguage(lang: language)
    }
}

extension String {
    func localized(lang:String) -> String? {
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj") {
            if let bundle = Bundle(path: path) {
                return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
            }
        }

        return nil;
    }
}

struct SettingsRowWithCheckbox: View {

    var mCurrentRowData:CheckBoxRowData
   
    @Binding var mSelectedCheckBoxRowData: CheckBoxRowData?
    
    var noLineAfter = 0
    
    var isSelected = true

    var body: some View {

        VStack {
            HStack{
                
                Text(mCurrentRowData.title)
                    .multilineTextAlignment(.leading)
                    .scaledFont(size: 16)
                    .foregroundColor(isCurrentIndexSelected() ? Color.arrrBarAccentColor : Color.textTitleColor)
                    .padding(.trailing, isCurrentIndexSelected() ? 60 : 80)
                    .frame(height: 22,alignment: .leading)
                                .foregroundColor(Color.white)
                    .padding()
                Spacer()
              
                if isCurrentIndexSelected() {
                    Image(systemName: "checkmark").resizable().frame(width: 10, height: 10, alignment: .trailing).foregroundColor(isCurrentIndexSelected() ? Color.arrrBarAccentColor : Color.textTitleColor)
                        .padding(.trailing,10)
                }
            }.contentShape(Rectangle())
            if mCurrentRowData.id < noLineAfter {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            }
        }
    }
    
    func isCurrentIndexSelected() -> Bool{
        return UserSettings.shared.languageSelectionIndex == mCurrentRowData.id ? true : false
    }
}

struct SelectLanguage_Previews: PreviewProvider {
    static var previews: some View {
        SelectLanguage(languageViewModel: SelectLanguageViewModel())
    }
}
