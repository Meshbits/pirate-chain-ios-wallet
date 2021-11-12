//
//  RescanOptionsView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 30/10/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import AlertToast
class RescanDataViewModel: ObservableObject {
    
    @Published var allBirthdays = [CheckBoxRowData(id:0,title:"Temp",isSelected: true)]
    
    @Published var mSelectedIndex = 0
        
     var anArrayOfBirthdays = [1640000,1630000,1620000,1610000,1600000,
                               1590000,1580000,1570000,1560000,1550000,1540000,1530000,1520000,1510000,1500000,
                               1490000,1480000,1470000,1460000,1450000,1440000,1430000,1420000,1410000,1400000,
                               1390000,1380000,1370000,1360000,1350000,1340000,1330000,1320000,1310000,1300000,
                               1290000,1280000,1270000,1260000,1250000,1240000,1230000,1220000,1210000,1200000,
                               1190000,1180000,1170000,1160000,1150000,1140000,1130000,1120000,1110000,1100000,
                               1090000,1080000,1070000,1060000,1050000,1040000,1030000,1020000,1010000,1000000,
                                900000,800000,700000,600000,500000,400000,300000,200000]
     
    init() {
        createAndUpdateCheckBoxContentOfBirthdays()
        updateBirthdaySelectionStatus()
    }
    
    func createAndUpdateCheckBoxContentOfBirthdays(){
        
        allBirthdays.removeAll()
        
        let mCurrentWalletBirthday = (try? SeedManager.default.exportBirthday()) ?? SeedManager.mDefaultHeight
        
        for index in 0...anArrayOfBirthdays.count-1 {
            if anArrayOfBirthdays[index] == mCurrentWalletBirthday{
                mSelectedIndex = index
                allBirthdays.append(CheckBoxRowData(id:index,title:String.init(format: "%d",anArrayOfBirthdays[index]),isSelected: true))
            }else{
                allBirthdays.append(CheckBoxRowData(id:index,title:String.init(format: "%d",anArrayOfBirthdays[index]),isSelected: false))
            }
        }
    }
    
    func updateBirthdaySelectionStatus(){
        for var checkBoxData in allBirthdays {
            if checkBoxData.id == mSelectedIndex {
                checkBoxData.isSelected = true
            }else{
                checkBoxData.isSelected = false
            }
        }
    }
    
    func getSelectedCheckboxObject()->CheckBoxRowData {
        return allBirthdays[mSelectedIndex]
    }
    
}

struct RescanOptionsView: View {

    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var rescanDataViewModel: RescanDataViewModel
    
    @State var mSelectedSettingsRowData: CheckBoxRowData?
    
    @State var showScanStartedToast = false
    
    @State var showErrorScanToast = false
    
    @State var mCurrentWalletBirthday = SeedManager.mDefaultHeight
       
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    var body: some View {
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                
                List {
                    
                    ForEach(rescanDataViewModel.allBirthdays, id: \.id) { settingsRowData in
                        
                        RescanRowWithCheckbox(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:48, isSelected: settingsRowData.isSelected)
                            .onTapGesture {
                                self.mSelectedSettingsRowData = settingsRowData
                                self.rescanDataViewModel.mSelectedIndex = mSelectedSettingsRowData!.id
                                self.rescanDataViewModel.updateBirthdaySelectionStatus()
                            }
                            .listRowBackground(Color.clear)
                            .frame(height: 69)
                            .cornerRadius(0)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                }
                .modifier(BackgroundPlaceholderModifierHome())
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zGray, lineWidth: 1.0)
                )
                .padding()
               
                
                Spacer(minLength: 50)
                
                Button {
                    
                    if let height = mSelectedSettingsRowData?.title {
                        // Index of selection
//                        print("height=\(height)")
                        
                        mCurrentWalletBirthday = Int(height) ?? SeedManager.mDefaultHeight
                        
                        if self.appEnvironment.synchronizer.syncStatus.value != .synced {
                                self.showErrorScanToast = true
                        }else{
                            
                            showScanStartedToast = true
                            
                            (try? SeedManager.default.importNewBirthdayOnRescan(mCurrentWalletBirthday))
                            
                            self.appEnvironment.synchronizer.rescanWithBirthday(blockheight: mCurrentWalletBirthday)

                        }
                        
                    }else{
                        
                        if self.appEnvironment.synchronizer.syncStatus.value != .synced {
                                self.showErrorScanToast = true
                        }else{
                            
                            showScanStartedToast = true
                            
                            mCurrentWalletBirthday = (try? SeedManager.default.exportBirthday()) ?? SeedManager.mDefaultHeight
                            
                            self.appEnvironment.synchronizer.fullRescan()
                        }
                    }
                    
                } label: {
                    BlueButtonView(aTitle: "Rescan Now".localized())
                }
      
            }
            
            
        }.toast(isPresenting: $showScanStartedToast){
            
            AlertToast(displayMode: .hud, type: .regular, title:"Rescanning started with height:".localized() + "\(mCurrentWalletBirthday)")

        }
        .toast(isPresenting: $showErrorScanToast){
            
            AlertToast(displayMode: .hud, type: .regular, title:"Please wait, existing downloading/scanning is in progress.".localized())

        }
        
        
        .onAppear(perform: {
            
            mSelectedSettingsRowData = rescanDataViewModel.getSelectedCheckboxObject()
            
        })
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Select Rescan Wallet Height").navigationBarTitleDisplayMode(.inline)
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

struct RescanRowWithCheckbox: View {

    @State var mCurrentRowData:CheckBoxRowData
    
    @Binding var mSelectedSettingsRowData: CheckBoxRowData?
   
    var noLineAfter = 0
    
    @State var isSelected = true

    var body: some View {

        VStack {
            HStack{
                
                Text(mCurrentRowData.title)
                    .multilineTextAlignment(.leading)
                    .scaledFont(size: 16)
                    .foregroundColor(mSelectedSettingsRowData?.id == mCurrentRowData.id ? Color.arrrBarAccentColor : Color.textTitleColor)
                    .padding(.trailing, mCurrentRowData.isSelected ? 60 : 80)
                    .frame(height: 22,alignment: .leading)
                                .foregroundColor(Color.white)
                    .padding()
                Spacer()
              
                Image(systemName: "checkmark").resizable().frame(width: 10, height: 10, alignment: .trailing).foregroundColor(mSelectedSettingsRowData?.id == mCurrentRowData.id ? Color.arrrBarAccentColor : Color.textTitleColor)
                    .padding(.trailing,10).opacity(mSelectedSettingsRowData?.id == mCurrentRowData.id ? 1 : 0)
            }.contentShape(Rectangle())
//            if mCurrentRowData.id < noLineAfter {
//                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
//            }
        }
    }
}

//struct RescanOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RescanOptionsView()
//    }
//}
