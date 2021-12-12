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
            return 1
        case .word_two:
            return 2
        case .word_three:
            return 3
        case .word_four:
            return 4
        case .word_five:
            return 5
        case .word_six:
            return 6
        case .word_seven:
            return 7
        case .word_eight:
            return 8
        case .word_nine:
            return 9
        case .word_ten:
            return 10
        case .word_eleven:
            return 11
        case .word_twelve:
            return 12
        case .word_thirteen:
            return 13
        case .word_fourteen:
            return 14
        case .word_fifteen:
            return 15
        case .word_sixteen:
            return 16
        case .word_seventeen:
            return 17
        case .word_eighteen:
            return 18
        case .word_nineteen:
            return 19
        case .word_twenty:
            return 20
        case .word_twenty_one:
            return 21
        case .word_twenty_two:
            return 22
        case .word_twenty_three:
            return 23
        case .word_twenty_four:
            return 24
        case .word_next:
            return 25
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
    
    @Published var mWordsVerificationScreen = false
    
    init() {
        
        do {
            randomKeyPhrase =  try MnemonicSeedProvider.default.randomMnemonicWords()
            
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
            mWordsVerificationScreen = true
            backPressedToPopBack()
        }else{
            mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
        }
    }
    
}

struct GenerateWordsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: GenerateWordsViewModel
    
    @State var isForward = true
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, content: {
                Text("Your Recovery Phrase".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                    .scaledFont(size: Device.isLarge ? 26 : 20)
                    .padding(.top,20)
                Text("Write down the following words in order".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: 15)
                Spacer()
                Text(self.viewModel.mWordTitle)/*.transition(.move(edge: isForward ? .trailing : .leading))*/.id("titleComponentID" + self.viewModel.mWordTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
//                    .transition(
//                        .asymmetric(
//                            insertion: .move(edge: isForward ? .trailing : .leading),
//                            removal: .move(edge: isForward ? .leading : .trailing)
//                        )
//                    )
//                    .animation(.default)
//                    .id(UUID())
                    .padding(.top,80)
                Text("\(self.viewModel.mWordIndex) of 24").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: 17)
                Spacer()
                
//                Image(self.viewModel.mWordIndex%2==0 ? "leftbgwords" : "rightbgwords")
//                    .transition(
//                    .asymmetric(
//                        insertion: .move(edge: isForward ? .trailing : .leading),
//                        removal: .move(edge: isForward ? .leading : .trailing)
//                    )
//                )
//                .animation(.default)
//                .id(UUID())
                
                Text("For security purposes, do not screeshot or email these words.".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.gray).multilineTextAlignment(.leading).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: 12)
                Button {
                    self.isForward = true
//                    withAnimation(.easeInOut(duration: 0.2), {
                        self.viewModel.updateLayoutTextOrMoveToNextScreen()
//                   })
                } label: {
                    BlueButtonView(aTitle: "Next".localized())
                }
              
                
                NavigationLink(
                    destination: WordsVerificationScreen().environmentObject(WordsVerificationViewModel(mPhrase:self.viewModel.randomKeyPhrase!)).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                    isActive: $viewModel.mWordsVerificationScreen
                ) {
                    EmptyView()
                }
                
            })  .navigationBarBackButtonHidden(true)
                .navigationTitle("").navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    if self.viewModel.mWordIndex == 1 {
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        isForward = false
//                        withAnimation(.easeIn(duration: 0.2), {
                            self.viewModel.backPressedToPopBack()
//                       })
                    }
                    
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("backicon").resizable().frame(width: 50, height: 50)
                        }
                    }
                })
                
            
        }
        .highPriorityGesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
            
            if value.translation.width < 0 && value.translation.height > -80 && value.translation.height < 80 {
//                withAnimation(.easeInOut(duration: 0.2), {
                    self.isForward = true
                    self.viewModel.updateLayoutTextOrMoveToNextScreen()
//               })
            }
            else if value.translation.width > 0 && value.translation.height > -80 && value.translation.height < 80 {
//                withAnimation(.easeIn(duration: 0.2), {
                    self.isForward = false
                    self.viewModel.backPressedToPopBack()
//               })
            }
            else {
                print("other gesture we don't worry about")
            }
        })
    }
    
}

struct GenerateWordsView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateWordsView()
    }
}

