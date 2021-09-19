//
//  RecoveryWordsView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 11/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class RecoveryWordsViewModel: ObservableObject {
    
    @Published var mWordTitle = ""
    
    @Published var mWordIndex = 1
    
    @Published var mVisibleWord: Words = Words.word_one
    
    var randomKeyPhrase:[String]?
    
    @Published var mPopToPreviousScreen = false
    
    init() {
        
        do {
            randomKeyPhrase =  try MnemonicSeedProvider.default.savedMnemonicWords()
            print(randomKeyPhrase)
            
            mWordTitle = randomKeyPhrase![0]
            
        } catch {
            // Handle error in here
        }
        
    }
    
    
    func backPressedToPopBack(){
        
        mVisibleWord.previous()
        
        mWordIndex = mVisibleWord.rawValue + 1
        
        mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
    }
    
    
    func updateLayoutTextOrMoveToNextScreen(){
        
        mVisibleWord.next()
        
        mWordIndex = mVisibleWord.rawValue + 1
        
        if mWordIndex > 24 {
            mPopToPreviousScreen = true
            backPressedToPopBack()
        }else{
            mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
        }
    }
    
}

struct RecoveryWordsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: RecoveryWordsViewModel
    
    var body: some View {
        ZStack{
           
            VStack(alignment: .center, content: {
                Text("Your Recovery Phrase".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text("Write down the following words in order".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                Text(self.viewModel.mWordTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text("\(self.viewModel.mWordIndex) of 24").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                
                Spacer()
                
                Text("For security purposes, do not screeshot or email these words.".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                Button {

                    self.viewModel.updateLayoutTextOrMoveToNextScreen()

                    
                    if self.viewModel.mPopToPreviousScreen {
                        self.presentationMode.wrappedValue.dismiss()
                    }

                } label: {
                    BlueButtonView(aTitle:self.viewModel.mWordIndex == 24 ? "Close".localized() : "Next".localized())
                }
                
            })
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .zcashNavigationBar(leadingItem: {
            
            
            ARRRBackButton(action: {
                if self.viewModel.mWordIndex == 1 {
                    presentationMode.wrappedValue.dismiss()
                }else{
                    self.viewModel.backPressedToPopBack()
                }
                
            }).frame(width: 30, height: 30)
            .padding(.top,10)
        }, headerItem: {
            HStack{
                EmptyView()
            }
        }, trailingItem: {
            ARRRCloseButton(action: {
                presentationMode.wrappedValue.dismiss()
                }).frame(width: 30, height: 30).padding(.top,20)
            
        })
    }
    
}

struct RecoveryWordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryWordsView()
    }
}
