//
//  WordsVerificationScreen.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 28/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import AlertToast
final class WordsVerificationViewModel: ObservableObject {
    
    @Published var firstWord = ""
    @Published var secondWord = ""
    @Published var thirdWord = ""
    @Published var firstWordIndex:Int = 0
    @Published var secondWordIndex:Int = 0
    @Published var thirdWordIndex:Int = 0
    @Published var mCompletePhrase:[String]?
    @Published var mWordsVerificationCompleted = false
  
    init(mPhrase:[String]) {
        mCompletePhrase = mPhrase
        
        assignElementsOnUI()
        
        print(mCompletePhrase)
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
        
        if (!firstWord.isEmpty && firstWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![firstWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
            
            if (!secondWord.isEmpty && secondWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![secondWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                
                if (!thirdWord.isEmpty && thirdWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![thirdWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                    
                    mWordsVerificationCompleted = true
                    
                    print("MATCHED")
                    
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
                    print("NOT MATCHED AND NOTIFY USER")
                }
            }else{
                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
                print("NOT MATCHED AND NOTIFY USER")
            }
            
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
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
    @ObservedObject var viewModel: WordsVerificationViewModel
    @State var isConfirmButtonEnabled = false
    @State private var showErrorToast = false

    var body: some View {
//        NavigationView {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Confirm Recovery Phrase".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                    .scaledFont(size: Device.isLarge ? 28 : 20).padding(.top,20)
                Text("Almost done! Enter the following words from your recovery phrase".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: 14)
                
                HStack(spacing: nil, content: {
                   
                    VStack{
                        Text("Word #\(self.viewModel.firstWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).scaledFont(size: 14)
                        TextField("".localized(), text: self.$viewModel.firstWord, onEditingChanged: { (changed) in
                        }) {
     //                       self.didEndEditingAddressTextField()
                        }
                        .scaledFont(size: 14)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                    
                    VStack{
                        Text("Word #\(self.viewModel.secondWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).scaledFont(size: 14)
                        TextField("".localized(), text: self.$viewModel.secondWord, onEditingChanged: { (changed) in
                        }){
      //                      self.didEndEditingPortTextField()
                        }.scaledFont(size: 14)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                     
                    VStack{
                        Text("Word #\(self.viewModel.thirdWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).scaledFont(size: 14)
                        TextField("".localized(), text: self.$viewModel.thirdWord, onEditingChanged: { (changed) in
                        }) {
      //                      self.didEndEditingPortTextField()
                        }.scaledFont(size: 14)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                                           
                }).modifier(ForegroundPlaceholderModifier())
                .padding(10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Confirm".localized()).onTapGesture {
                    if self.viewModel.firstWord.isEmpty || self.viewModel.secondWord.isEmpty || self.viewModel.thirdWord.isEmpty {
                        self.isConfirmButtonEnabled = false
                    }else{
                        self.isConfirmButtonEnabled = true
                    }
                    
                    self.viewModel.validateAndMoveToNextScreen()
                    
                }.padding(.bottom,10)
                
                
                NavigationLink(
                    destination: CongratulationsRecoverySetup().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $viewModel.mWordsVerificationCompleted
                ) {
                    EmptyView()
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
           
        } .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear(){
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil, queue: .main) { (_) in
                showErrorToast = true
                aSmallErrorVibration()
            }
        }.toast(isPresenting: $showErrorToast){
            
            AlertToast(displayMode: .hud, type: .regular, title:"Invalid passphrase!".localized())

        }
        .navigationBarBackButtonHidden(true)
           .navigationTitle("").navigationBarTitleDisplayMode(.inline)
           .navigationBarItems(leading:  Button(action: {
               presentationMode.wrappedValue.dismiss()
           }) {
               VStack(alignment: .leading) {
                   ZStack{
                       Image("backicon").resizable().frame(width: 50, height: 50)
                   }
               }
           })
//        }
     
    }
    
    func aSmallErrorVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.error)
    }
}

//struct WordsVerificationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        WordsVerificationScreen()
//    }
//}

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
