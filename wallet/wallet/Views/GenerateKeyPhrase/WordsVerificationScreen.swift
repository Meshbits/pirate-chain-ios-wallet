//
//  WordsVerificationScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 28/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

final class WordsVerificationViewModel: ObservableObject {
    
    @Published var firstWord = ""
    @Published var secondWord = ""
    @Published var thirdWord = ""
    @State var firstWordIndex:Int = 0
    @State var secondWordIndex:Int = 0
    @State var thirdWordIndex:Int = 0
    @Published var mCompletePhrase:[String]?
    @Published var mWordsVerificationCompleted = false
  
    init(mPhrase:[String]) {
        mCompletePhrase = mPhrase
    }
    
    func assignElementsOnUI(){
        
        let indexes = getRandomWordsIndex()
        
        if (mCompletePhrase!.count > 0){
            firstWordIndex = indexes[0]
            secondWordIndex = indexes[1]
            thirdWordIndex = indexes[2]
        }
        
    }
    
    
    func validateAndMoveToNextScreen(){
        
        if (!firstWord.isEmpty && firstWord == mCompletePhrase![firstWordIndex]){
            
            if (!secondWord.isEmpty && secondWord == mCompletePhrase![secondWordIndex]){
                
                if (!thirdWord.isEmpty && thirdWord == mCompletePhrase![thirdWordIndex]){
                    
                    print("NOT MATCHED AND NOTIFY USER")
                    
                }else{
                    print("NOT MATCHED AND NOTIFY USER")
                }
            }else{
                print("NOT MATCHED AND NOTIFY USER")
            }
            
        }else{
            print("NOT MATCHED AND NOTIFY USER")
        }
        
        
    }
    
    func getRandomWordsIndex()->[Int]{
          
          var allIndexes = Array(0...23)
        
          var uniqueNumbers = [Int]()
          
          while allIndexes.count > 0 {
              
              let number = Int(arc4random_uniform(UInt32(allIndexes.count)))
              
                uniqueNumbers.append(allIndexes[number])
              
                allIndexes.swapAt(number, allIndexes.count-1)
              
                allIndexes.removeLast()
            
                if uniqueNumbers.count == 3 {
                    break
                }
          }
          
          return uniqueNumbers
      }
    
}

struct WordsVerificationScreen: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: WordsVerificationViewModel
    @State var isConfirmButtonEnabled = false
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Confirm Recovery Phrase").padding(.trailing,80).padding(.leading,80).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,50)
                Text("Almost done! Enter the following words from your recovery phrase").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                HStack(spacing: nil, content: {
                   
                    VStack{
                        Text("Word # \(self.viewModel.firstWordIndex)").foregroundColor(.gray).multilineTextAlignment(.leading).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.firstWord, onEditingChanged: { (changed) in
                        }) {
     //                       self.didEndEditingAddressTextField()
                        }.font(.barlowRegular(size: 14))
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                    
                    VStack{
                        Text("Word # \(self.viewModel.secondWordIndex)").foregroundColor(.gray).multilineTextAlignment(.leading).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.secondWord, onEditingChanged: { (changed) in
                        }) {
      //                      self.didEndEditingPortTextField()
                        }.font(.barlowRegular(size: 14))
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                     
                    VStack{
                        Text("Word # \(self.viewModel.thirdWordIndex)").foregroundColor(.gray).multilineTextAlignment(.leading).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.thirdWord, onEditingChanged: { (changed) in
                        }) {
      //                      self.didEndEditingPortTextField()
                        }.font(.barlowRegular(size: 14))
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                                           
                }).modifier(ForegroundPlaceholderModifier())
                .padding(10)
                Spacer()
                Spacer()
                Spacer()
                
                BlueButtonView(aTitle: "Confirm").onTapGesture {
                    if self.viewModel.firstWord.isEmpty || self.viewModel.secondWord.isEmpty || self.viewModel.thirdWord.isEmpty {
                        self.isConfirmButtonEnabled = false
                    }else{
                        self.isConfirmButtonEnabled = true
                    }
                    
                    self.viewModel.validateAndMoveToNextScreen()
                    
                }
            }
            .onAppear(){
                self.viewModel.assignElementsOnUI()
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .zcashNavigationBar(leadingItem: {
                ARRRBackButton(action: {
                    presentationMode.wrappedValue.dismiss()
                }).frame(width: 30, height: 30)
            }, headerItem: {
                EmptyView()
            }, trailingItem: {
                EmptyView()
            })
        }
        
    }
}

struct WordsVerificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        WordsVerificationScreen()
    }
}

struct WordBackgroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 10), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
        .padding(2)
    }
}
