//
//  KeyPadARRR.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 24/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct KeyPadARRR: View {
    
    let keySize: CGFloat = 50
    let hSpacing: CGFloat = 10
    let vSpacing: CGFloat = 5
    
    var viewModel: KeyPadViewModel
    
    init(value: Binding<String>) {
        self.viewModel = KeyPadViewModel(value: value)
    }
    
    func aSmallVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.warning)
    }
    
    var body: some View {
            VStack(alignment: .center, spacing: self.vSpacing) {
             
                ForEach(self.viewModel.visibleValues, id: \.self) {
                    row in
                    HStack(alignment: .center, spacing: self.hSpacing) {
                        ForEach(row, id: \.self) { pad in
                            HStack {
                                if pad == "<" {
                                    Button(action: {
                                        aSmallVibration()
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                        ZStack{
                                            Image("passcodenumericbg")
                                            Image(systemName: "delete.left.fill").foregroundColor(.gray)
                                                .scaledFont(size: 20).foregroundColor(.gray)
                                        }
                                    }
                                    .buttonStyle(KeyPadButtonStyleARRR(size: self.keySize))
                                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                                        self.viewModel.clear()
                                    })
                                } else {
                                    Button(action: {
                                        aSmallVibration()
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                        ZStack{
                                            Image("passcodenumericbg")
                                            Text(pad)
                                                .scaledFont(size: 20).foregroundColor(.gray)
                                        }

                                    }
                                    .buttonStyle(KeyPadButtonStyleARRR(size: self.keySize))
                                }
                            }
                        }
                    }
                }
            }
        
    }
}

struct KeyPadButtonStyleARRR: ButtonStyle {
    let size: CGFloat
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(
                minWidth: size,
                maxWidth:  .infinity,
                minHeight:  size,
                maxHeight:  .infinity,
                alignment: .center
            )
            .contentShape(Circle())
            .animation(nil)
            .foregroundColor(configuration.isPressed ? Color.black : .white)
            .animation(.easeInOut(duration: 0.2))
    }
}
