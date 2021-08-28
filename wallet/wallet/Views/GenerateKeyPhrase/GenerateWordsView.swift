//
//  GenerateWordsView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 28/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit


enum Words: Int {
    case word_one
    case word_two
    case word_three
    case word_four
    case word_five
    case word_six
    case word_seven
    case word_eight
    case word_nine
    case word_ten
    case word_eleven
    case word_twelve
    case word_thirteen
    case word_fourteen
    case word_fifteen
    case word_sixteen
    case word_seventeen
    case word_eighteen
    case word_nineteen
    case word_twenty
    case word_twenty_one
    case word_twenty_two
    case word_twenty_three
    case word_twenty_four
    case word_next
    
    
    var id: Int {
        switch self {
        case .word_one:
            return 0
        case .word_two:
            return 1
        case .word_three:
            return 2
        case .word_four:
            return 3
        case .word_five:
            return 4
        case .word_six:
            return 5
        case .word_seven:
            return 6
        case .word_eight:
            return 7
        case .word_nine:
            return 8
        case .word_ten:
            return 9
        case .word_eleven:
            return 10
        case .word_twelve:
            return 11
        case .word_thirteen:
            return 12
        case .word_fourteen:
            return 13
        case .word_fifteen:
            return 14
        case .word_sixteen:
            return 15
        case .word_seventeen:
            return 16
        case .word_eighteen:
            return 17
        case .word_nineteen:
            return 18
        case .word_twenty:
            return 19
        case .word_twenty_one:
            return 20
        case .word_twenty_two:
            return 21
        case .word_twenty_three:
            return 22
        case .word_twenty_four:
            return 23
        case .word_next:
            return 24
        }
    }
    
    mutating func next(){
        self = Words(rawValue: rawValue + 1) ?? Words(rawValue: 0)!
    }
    
    mutating func previous(){
        self = Words(rawValue: rawValue - 1) ?? Words(rawValue: 0)!
    }
}

final class GenerateWordsViewModel: ObservableObject {
    
    @Published var mWordTitle = ""
    
    @Published var mWordIndex = 1
    
    @Published var mVisibleWord: Words = Words.word_one
    
    var randomKeyPhrase:[String]?
    
    init() {
        
        do {
            randomKeyPhrase =  try MnemonicSeedProvider.default.randomMnemonicWords()
            
            mWordTitle = randomKeyPhrase![0]
            
            print("randomKeyPhrase")
            print(randomKeyPhrase)
        } catch {
            // Handle error in here
        }
        
    }
    
    
    func backPressedToPopBack(){
        
        mVisibleWord.previous()
        
        mWordIndex = mVisibleWord.rawValue - 1
        
        mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
    }
    
    
    func updateLayoutTextOrMoveToNextScreen(){
        
        mVisibleWord.next()
        
        mWordIndex = mVisibleWord.rawValue + 1
        
        mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
    }
    
}

struct GenerateWordsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: GenerateWordsViewModel
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, content: {
                Text("Your Recovery Phrase").padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text("Write down the following words in order").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                Text(self.viewModel.mWordTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                Text("\(self.viewModel.mWordIndex) of 24").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Spacer()
                
                Spacer()
                
                Text("For security purposes, do not screeshot or email these words.").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                Button {
                    self.viewModel.updateLayoutTextOrMoveToNextScreen()
                } label: {
                    BlueButtonView(aTitle: "Next")
                }
                
            })
            
        }.zcashNavigationBar(leadingItem: {
            
            
            ARRRBackButton(action: {
                if self.viewModel.mWordIndex == 0 {
                    presentationMode.wrappedValue.dismiss()
                }else{
                    self.viewModel.backPressedToPopBack()
                }
                
            }).frame(width: 30, height: 30)
            .padding(.bottom,10)
            
            
        }, headerItem: {
            HStack{
                EmptyView()
            }
        }, trailingItem: {
            EmptyView()
        })
    }
    
}

struct GenerateWordsView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateWordsView()
    }
}
