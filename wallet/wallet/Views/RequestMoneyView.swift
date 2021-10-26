//
//  RequestMoneyView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 24/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct RequestMoneyView<AccesoryContent: View>: View {
    let qrSize: CGFloat = 100
    @State var isShareAddressShown = false
    @State var sendArrrValue =  ""
    @State var memoTextContent =  ""

    @State var copyItemModel: PasteboardItemModel?
    var address: String
    var qrImage: Image {
        if let img = QRCodeGenerator.generate(from: self.address) {
            return Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(self.address)") ))
        } else {
            return Image("zebra_profile")
        }
    }
    var badge: Image
    var chips: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var accessoryContent: AccesoryContent
    
    
    var validForm: Bool {
        sufficientAmount && validMemo
    }
    
    var sufficientAmount: Bool {
        let amount = (Double(sendArrrValue) ??  0 )
        return amount > 0 ? true : false
    }
    
    var validMemo: Bool {
        memoTextContent.count >= 0 && memoTextContent.count <= ZECCWalletEnvironment.memoLengthLimit
    }
    
    init(address: String, chips: Int = 8, badge: Image, @ViewBuilder accessoryContent: (() -> (AccesoryContent))) {
        self.address = address
        self.chips = address.slice(into: chips)
        self.badge = badge
        self.accessoryContent = accessoryContent()
    }
    
    var body: some View {
        ZStack{
            ARRRBackground()
            VStack{
                
                HStack{
                    QRCodeContainer(qrImage: qrImage,
                                    badge: badge)
                        .frame(width: qrSize, height: qrSize, alignment: .center)
                        .layoutPriority(1)
                        .cornerRadius(6)
                        .modifier(QRCodeBackgroundPlaceholderModifier())
                    
                    Button(action: {
                        PasteboardAlertHelper.shared.copyToPasteBoard(value: self.address, notify: "feedback_addresscopied".localized())
                        logger.debug("address copied to clipboard")
                 
                        tracker.track(.tap(action: .copyAddress), properties: [:])
                    }) {
                        VStack {
                            if chips.count <= 2 {
                                
                                ForEach(0 ..< chips.count) { i in
                                    AddressFragment(number: i + 1, word: self.chips[i])
                                        .frame(height: 24)
                                }
                                self.accessoryContent
                            } else {
                                ForEach(stride(from: 0, through: chips.count - 1, by: 2).map({ i in i}), id: \.self) { i in
                                    HStack {
                                        AddressFragmentWithoutNumber(word: self.chips[i])
                                            .frame(height: 24)
                                        AddressFragmentWithoutNumber(word: self.chips[i+1])
                                            .frame(height: 24)
                                    }
                                }
                            }
                            
                        }
                        .frame(minHeight: 96)
                        .padding(.leading, -10)
                        
                    }.alert(item: self.$copyItemModel) { (p) -> Alert in
                        PasteboardAlertHelper.alert(for: p)
                    }
                    .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
                        self.copyItemModel = p
                    }
                    
                    Spacer()
                }

                HStack{
                    Text("Memo".localized())
                        .scaledFont(size: 20).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:$memoTextContent).frame(height:55)
                
//                Text(self.sendArrrValue)
//                    .foregroundColor(.gray)
//                    .scaledFont(size: 26)
//                    .frame(height:30)
//                    .padding(.leading,10)
//                    .padding(.trailing,10)
//                    .modifier(BackgroundPlaceholderModifier())
//
                ARRRSendReceiveMoneyTextField(anAmount: self.$sendArrrValue)
                
                Spacer()
                
                BlueButtonView(aTitle: "Share".localized()).onTapGesture {
                    self.isShareAddressShown = true
                }.opacity(validForm ? 1.0 : 0.7 )
                .disabled(!validForm)
                
            }
            
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .keyboardAdaptive()
        .zcashNavigationBar(leadingItem: {
            EmptyView()
         }, headerItem: {
             HStack{
                 Text("Request Money".localized())
                    .scaledFont(size: 24)
                    .foregroundColor(Color.zSettingsSectionHeader)
                    .padding(.top,20)
             }
         }, trailingItem: {
             ARRRCloseButton(action: {
                 UIApplication.shared.endEditing()
                 presentationMode.wrappedValue.dismiss()
             }).frame(width: 15, height: 15).padding(.top,20)
         })
        .onAppear {
            tracker.track(.screen(screen: .receive), properties: [:])
        }
        .navigationBarHidden(true)
        .sheet(isPresented: self.$isShareAddressShown) {
            ShareSheet(activityItems: [getPirateChainURI()])
        }
    }
    
    func getPirateChainURI() -> String {
        return PirateChainPaymentURI.init(build: {
            $0.address = self.address
            $0.amount = Double(self.sendArrrValue)
            $0.label = ""
            $0.message = self.memoTextContent
            $0.isDeepLink = true
        }).uri ?? self.address
    }
}

//struct RequestMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        RequestMoneyView()
//    }
//}
