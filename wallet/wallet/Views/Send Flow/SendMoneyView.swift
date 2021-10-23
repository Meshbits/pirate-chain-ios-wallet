//
//  SendMoneyView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 25/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct SendMoneyView: View {
    
    @State var isSendTapped = false
    @EnvironmentObject var flow: SendFlowEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var scanViewModel = ScanAddressViewModel(shouldShowSwitchButton: false, showCloseButton: true)
    @State var adjustTransaction = false
    @State var validateTransaction = false
    @State var validatePinBeforeInitiatingFlow = false
    let dragGesture = DragGesture()
    var availableBalance: Bool {
        ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value > 0
    }
    
    var charLimit: Int {
        if flow.includeSendingAddress {
            return ZECCWalletEnvironment.memoLengthLimit - SendFlowEnvironment.replyToAddress((ZECCWalletEnvironment.shared.getShieldedAddress() ?? "")).count
        }
        return ZECCWalletEnvironment.memoLengthLimit
    }
    
    var validAddress: Bool {
        ZECCWalletEnvironment.shared.isValidAddress(flow.address)
    }
    
    var sufficientAmount: Bool {
        let amount = (flow.doubleAmount ??  0 )
        return amount > 0 && amount <= ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value
    }
    
    var isSendingAmountSameAsBalance:Bool{
        let amount = (flow.doubleAmount ??  0 )
        return amount > 0 && amount == ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value
    }
    
    var validForm: Bool {
        availableBalance && validAddress && sufficientAmount && validMemo
    }
    
    var validMemo: Bool {
        flow.memo.count >= 0 && flow.memo.count <= charLimit
    }
    
    var addressSubtitle: String {
        let environment = ZECCWalletEnvironment.shared
        guard !flow.address.isEmpty else {
            return "feedback_default".localized()
        }
        
        if environment.isValidShieldedAddress(flow.address) {
            return "feedback_shieldedaddress".localized()
        } else if environment.isValidTransparentAddress(flow.address) {
            return "feedback_transparentaddress".localized()
        } else if (environment.getShieldedAddress() ?? "") == flow.address {
            return "feedback_sameaddress".localized()
        } else {
            return "feedback_invalidaddress".localized()
        }
    }
    
    var recipientActiveColor: Color {
        let address = flow.address
        if ZECCWalletEnvironment.shared.isValidShieldedAddress(address) {
            return Color.arrrBlue
        } else {
            return Color.zGray2
        }
    }
    
    var body: some View {
        NavigationView {
        ZStack{
            ARRRBackground()
            VStack{
                
                ZcashActionableTextField(
                    title: "\("label_to".localized()):",
                    subtitleView: AnyView(
                        Text.subtitle(text: addressSubtitle)
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $flow.address,
                    action: {
                        tracker.track(.tap(action: .sendAddressScan),
                                      properties: [:])
                        self.flow.showScanView = true
                },
                    accessoryIcon: Image("QRCodeIcon")
                        .renderingMode(.original),
                    activeColor: recipientActiveColor,
                    onEditingChanged: { _ in },
                    onCommit: {
                        tracker.track(.tap(action: .sendAddressDoneAddress), properties: [:])
                }
                ).modifier(BackgroundPlaceholderModifierHome()).padding(.leading, 20).padding(.trailing, 20).padding(.top, 20)
                    .onReceive(scanViewModel.addressPublisher, perform: { (address) in
                        self.flow.address = address
                        self.flow.showScanView = false
                    })
                    .sheet(isPresented: self.$flow.showScanView) {
                        NavigationView {
                            LazyView(
                                
                                ScanAddress(
                                    viewModel: self.scanViewModel,
                                    cameraAccess: CameraAccessHelper.authorizationStatus,
                                    isScanAddressShown: self.$flow.showScanView
                                ).environmentObject(ZECCWalletEnvironment.shared)
                                
                            )
                        }
                }
                
                HStack{
                    Text("Memo".localized())
                        .scaledFont(size: 20)
                        .foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:self.$flow.memo).frame(height:60)
                
                HStack{
                    Text(self.flow.amount)
                        .foregroundColor(.gray)
                        .scaledFont(size: 30)
                        .frame(height:30)
                        .padding(.leading,10)
                        .padding(.trailing,10)
                        .modifier(BackgroundPlaceholderModifier())
                
                    SendMoneyButtonView(title: "Send Max".localized())
                        .onTapGesture {
                            let actualAmount = (ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value)
                            let defaultNetworkFee: Double = Int64(ZECCWalletEnvironment.defaultFee).asHumanReadableZecBalance() // 0.0001 minor fee
                            if (actualAmount > defaultNetworkFee){
                                flow.amount = String.init(format: "%.5f", (actualAmount-defaultNetworkFee))
                            }else{
                                // Can't adjust the amount, as its less than the fee
                            }
                        }
                }
                
               
                HStack{
                    Spacer()
                    Text("Processing fee: ".localized() + "\(Int64(ZECCWalletEnvironment.defaultFee).asHumanReadableZecBalance().toZecAmount())" + " ARRR")
                        .scaledFont(size: 14).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle)
                    Spacer()
                }
                              
                KeyPadARRR(value: $flow.amount)
                    .frame(alignment: .center)
                    .padding(.horizontal, 10)
                
                BlueButtonView(aTitle: "Send".localized()).onTapGesture {
                    
                    if isSendingAmountSameAsBalance {
                        // throw an alert here
                        adjustTransaction = true
                    }else{
                        validateTransaction = true
                    }
                }.opacity(validForm ? 1.0 : 0.7 )
                .disabled(!validForm)
                
                
                
                
                NavigationLink(
                    destination: LazyView(
                        Sending().environmentObject(flow)
                            .navigationBarTitle("",displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                    ), isActive: self.$isSendTapped
                ) {
                    EmptyView()
                }
                
                
                
            }.onTapGesture {
                UIApplication.shared.endEditing()
            }.zcashNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                     Text("Send Money".localized())
                         .font(.barlowRegular(size: 22)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center).padding(.top,30)
                        
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     self.onDismissRemoveObservers()
                     presentationMode.wrappedValue.dismiss()
                     }).frame(width: 20, height: 20)
                 .padding(.top,40)
             })
            .navigationBarHidden(true)
        }
        .highPriorityGesture(dragGesture)     
        .sheet(isPresented: $validateTransaction) {
            LazyView(ConfirmTransaction().environmentObject(flow))
        }
        .sheet(isPresented: $validatePinBeforeInitiatingFlow) {
            LazyView(PasscodeValidationScreen(passcodeViewModel: PasscodeValidationViewModel(), isAuthenticationEnabled: false))
        }
        .alert(isPresented:self.$adjustTransaction) {
            Alert(title: Text("Pirate Chain Wallet".localized()),
                         message: Text("We found your wallet didn't had enough funds for the fees, the transaction needs to been adjusted to cater the fee of 0.0001 ARRR. Please, confirm the adjustment in the transaction to include miner fee.".localized()),
                         primaryButton: .cancel(Text("Cancel".localized())),
                         secondaryButton: .default(Text("Confirm".localized()), action: {
                            
                            let amount = (flow.doubleAmount ??  0 )
                            let defaultNetworkFee: Double = Int64(ZECCWalletEnvironment.defaultFee).asHumanReadableZecBalance() // 0.0001 minor fee
                            if (amount > defaultNetworkFee && amount == ZECCWalletEnvironment.shared.synchronizer.verifiedBalance.value){
                                flow.amount = String.init(format: "%.5f", (amount-defaultNetworkFee))
                                validateTransaction = true
                            }else{
                                // Can't adjust the amount, as its less than the fee
                            }
                         }))
        }
        .onAppear(){
            NotificationCenter.default.addObserver(forName: NSNotification.Name("PasscodeValidationSuccessful"), object: nil, queue: .main) { (_) in
                flow.includesMemo = true
                isSendTapped = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ConfirmedTransaction"), object: nil, queue: .main) { (_) in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    validatePinBeforeInitiatingFlow = true
                }
            }
        }
        .keyboardAdaptive()
        }
    }
    
    func onDismissRemoveObservers() {
        NotificationCenter.default.removeObserver(NSNotification.Name("PasscodeValidationSuccessful"))
        NotificationCenter.default.removeObserver(NSNotification.Name("ConfirmedTransaction"))
    }
    
    var includesMemo: Bool {
        !self.flow.memo.isEmpty || self.flow.includeSendingAddress
    }

}

//struct SendMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendMoneyView()
//    }
//}

struct SendMoneyButtonView : View {
    
    @State var title: String
    
    var body: some View {
        ZStack{
            
            Image("buttonbackground").resizable().frame(width: 115)
            
            Text(title).foregroundColor(Color.zARRRTextColorLightYellow).bold().multilineTextAlignment(.center).font(
                .barlowRegular(size: 12)
            ).modifier(ForegroundPlaceholderModifierHomeButtons())
            .frame(width: 140)
            .padding([.bottom],4)
            .cornerRadius(30)
           
        }.frame(width: 120)
    }
}
