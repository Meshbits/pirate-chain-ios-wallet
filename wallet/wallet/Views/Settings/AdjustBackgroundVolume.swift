//
//  AdjustBackgroundVolume.swift
//  ECC-Wallet
//
//  Created by Lokesh on 17/02/22.
//  Copyright © 2022 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct AdjustBackgroundVolume: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var sliderValue: Float = UserSettings.shared.mBackgroundSoundVolume ?? 0.05
    
    @State var isChecked = UserSettings.shared.isForegroundSoundEnabled ?? true
    
    var body: some View {
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                                  
                Slider(value: $sliderValue, in: 0.05...1, step: 0.05)
                    .accentColor(Color.arrrBarAccentColor)
                    .frame(height: 40)
                    .padding(.leading,50)
                    .padding(.trailing,50)
                      .padding(.horizontal)
                Text("\(sliderValue, specifier: "%.2f")")
                    .scaledFont(size: Device.isLarge ?  16 : 12)
                    .foregroundColor(Color.textTitleColor)
                
                VolumeCheckBoxView(isChecked: $isChecked, title: "Enable Sound in foreground".localized())
                    .padding(.top,80)
      
            }
            .padding(.top,40)
            
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Adjust Background Volume".localized()).navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack(alignment: .leading) {
                ZStack{
                    Image("backicon").resizable().frame(width: 50, height: 50)
                }
            }
        })
        .onDisappear {
            UserSettings.shared.mBackgroundSoundVolume = sliderValue
        }
    }
}

struct VolumeCheckBoxView: View {
    
    @Binding var isChecked:Bool
    
    var title:String
    
    func toggle()
    {
        isChecked = !isChecked
        UserSettings.shared.isForegroundSoundEnabled = isChecked
    }
    
    var body: some View {
        Button(action: toggle){
            HStack{
                Image(systemName: isChecked ? "checkmark.square": "square")
                    .scaledFont(size: Device.isLarge ?  20 : 16)
                Text(title)
                    .scaledFont(size: Device.isLarge ?  20 : 16)
                    .foregroundColor(Color.textTitleColor)
            }

        }

    }

}
