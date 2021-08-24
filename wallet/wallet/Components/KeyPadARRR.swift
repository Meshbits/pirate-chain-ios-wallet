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
        self.viewModel.value = "0"
    }
    
    var body: some View {
            VStack(alignment: .center, spacing: self.vSpacing) {
                
                Text(self.viewModel.value)
                    .foregroundColor(.gray)
                    .font(.barlowRegular(size: Device.isLarge ? 40 : 30))
                    .frame(height:40)
                    .padding(.leading,10)
                    .padding(.trailing,10)
                    .modifier(BackgroundPlaceholderModifier())
                
                ForEach(self.viewModel.visibleValues, id: \.self) {
                    row in
                    HStack(alignment: .center, spacing: self.hSpacing) {
                        ForEach(row, id: \.self) { pad in
                            HStack {
                                if pad == "<" {
                                    Button(action: {
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                        ZStack{
                                            Image("passcodenumericbg")
                                            Image(systemName: "delete.left.fill").foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 22 : 14)).foregroundColor(.gray)
                                        }
                                    }
                                    .buttonStyle(KeyPadButtonStyleARRR(size: self.keySize))
                                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                                        self.viewModel.clear()
                                    })
                                } else {
                                    Button(action: {
                                        self.viewModel.valuePressed(pad)
                                    }) {
                                        ZStack{
                                            Image("passcodenumericbg")
                                            Text(pad)
                                                .font(.barlowRegular(size: Device.isLarge ? 22 : 14)).foregroundColor(.gray)
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
            .background(Circle().fill(configuration.isPressed ? Color.white : .clear))
            .animation(.easeInOut(duration: 0.2))
    }
}
