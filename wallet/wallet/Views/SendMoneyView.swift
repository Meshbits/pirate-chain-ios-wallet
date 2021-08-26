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
            return Color.zYellow
        } else {
            return Color.zGray2
        }
    }
    
    var body: some View {
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
                    Text("Memo").font(.barlowRegular(size: 22)).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:self.$flow.memo).frame(height:60)
                
                Text(self.flow.amount)
                    .foregroundColor(.gray)
                    .font(.barlowRegular(size: Device.isLarge ? 40 : 30))
                    .frame(height:40)
                    .padding(.leading,10)
                    .padding(.trailing,10)
                    .modifier(BackgroundPlaceholderModifier())
            
                HStack{
                    Spacer()
                    Text("Processing fee: " + "\(ZcashSDK.defaultFee().asHumanReadableZecBalance().toZecAmount())" + " ARRR").font(.barlowRegular(size: 14)).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle)
                    Spacer()
                }
                              
                KeyPadARRR(value: $flow.amount)
                    .frame(alignment: .center)
                    .padding(.horizontal, 10)
                
                BlueButtonView(aTitle: "Send").onTapGesture {
                    isSendTapped = true
                }.opacity(validForm ? 1.0 : 0.7 )
                .disabled(!validForm)
                
            }.zcashNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                     Text("Send Money")
                         .font(.barlowRegular(size: 26)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center)
                        .padding(.top,20)
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     presentationMode.wrappedValue.dismiss()
                     }).frame(width: 30, height: 30)
                 .padding(.top,20)
             })
        }
    }
}

//struct SendMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendMoneyView()
//    }
//}
