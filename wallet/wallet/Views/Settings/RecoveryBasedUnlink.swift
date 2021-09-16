//
//  RecoveryBasedUnlink.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 03/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI


final class RecoveryViewModel: ObservableObject {
    
    @Published var firstWord = ""
    @Published var secondWord = ""
    @Published var thirdWord = ""
    @Published var firstWordIndex:Int = 0
    @Published var secondWordIndex:Int = 0
    @Published var thirdWordIndex:Int = 0
    var mSeedPhrase = try! SeedManager.default.exportPhrase()
    @Published var mCompletePhrase:[String]?
    @Published var mWordsVerificationCompleted = false
  
    init() {
        
        mCompletePhrase = mSeedPhrase.components(separatedBy: " ")
        assignElementsOnUI()
//        print(mCompletePhrase)
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
                    
                    print("MATCHED AND NOW UNLINK IT HERE")
                    
                    
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

struct RecoveryBasedUnlink: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: RecoveryViewModel
    @State var isConfirmButtonEnabled = false
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    var body: some View {
//        NavigationView {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Enter Recovery Phrase".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,40)
                Text("Please enter your recovery phrase to unlink the wallet from your device".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 20 : 14))
                
                HStack(spacing: nil, content: {
                   
                    VStack{
                        Text("Word #\(self.viewModel.firstWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.firstWord, onEditingChanged: { (changed) in
                        }) {
     //                       self.didEndEditingAddressTextField()
                        }.font(.barlowRegular(size: 14))
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                    
                    VStack{
                        Text("Word #\(self.viewModel.secondWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.secondWord, onEditingChanged: { (changed) in
                        }){
      //                      self.didEndEditingPortTextField()
                        }.font(.barlowRegular(size: 14))
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                     
                    VStack{
                        Text("Word #\(self.viewModel.thirdWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.thirdWord, onEditingChanged: { (changed) in
                        }) {
      //                      self.didEndEditingPortTextField()
                        }.font(.barlowRegular(size: 14))
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                                           
                }).modifier(ForegroundPlaceholderModifier())
                .padding(10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Unlink".localized()).onTapGesture {
                    if self.viewModel.firstWord.isEmpty || self.viewModel.secondWord.isEmpty || self.viewModel.thirdWord.isEmpty {
                        self.isConfirmButtonEnabled = false
                    }else{
                        self.isConfirmButtonEnabled = true
                    }
                    
                    self.viewModel.validateAndMoveToNextScreen()
                    
                }.padding(.bottom,10)
                .alert(isPresented: $viewModel.mWordsVerificationCompleted) {
                    Alert(title: Text("nuke_alerttitle".localized()),
                          message: Text("nuke_alertmessage".localized()),
                          primaryButton: .default(
                            Text("nuke_alertcancel".localized())
                            ,action: { }
                        ),
                          secondaryButton: .destructive(
                            Text("nuke_alertconfirm".localized()),
                            action: {
                                presentationMode.wrappedValue.dismiss()
                                UserSettings.shared.removeAllSettings()
                                self.appEnvironment.nuke(abortApplication: true)
//                                            try! self.appEnvironment.deleteWalletFiles()
//                                            presentationMode.wrappedValue.dismiss()
                                ZECCWalletEnvironment.shared.state = .uninitialized
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                      NotificationCenter.default.post(name: NSNotification.Name("MoveToFirstViewLayout"), object: nil)
                                }
                          }
                        )
                    )
                }
                
                
//                NavigationLink(
//                    destination: CongratulationsRecoverySetup().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true)
//                        .navigationBarBackButtonHidden(true),
//                    isActive: $viewModel.mWordsVerificationCompleted
//                ) {
//                    EmptyView()
//                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
           
        } .onTapGesture {
            UIApplication.shared.endEditing()
//        }
        }.zcashNavigationBar(leadingItem: {
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

