//
//  DisplayAddress.swift
//  wallet
//
//  Created by Francisco Gindre on 7/24/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import BottomSheet

struct DisplayAddress<AccesoryContent: View>: View {
    
    @State var copyItemModel: PasteboardItemModel?
    @State var isShareModalDisplayed = false
    @State var isShareAddressShown = false
    @State var openRequestMoney = false
    @State var openFullScreenQRCode = false
    var qrImage: Image
    var badge: Image
    var title: String
    var address: String
    var chips: [String]
    let qrSize: CGFloat = Device.isLarge ? 200 : 140
    var accessoryContent: AccesoryContent
    
    init(address: String, title: String, chips: Int = 8, badge: Image, qrImage:Image, @ViewBuilder accessoryContent: (() -> (AccesoryContent))) {
        self.address = address
        self.title = title
        self.chips = address.slice(into: chips)
        self.badge = badge
        self.qrImage = qrImage
        self.accessoryContent = accessoryContent()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
         
            QRCodeContainer(qrImage: qrImage,
                            badge: badge)
                .frame(width: qrSize, height: qrSize, alignment: .center)
                .layoutPriority(1)
                .cornerRadius(6)
                .modifier(QRCodeBackgroundPlaceholderModifier())
                .onTapGesture {
                    openFullScreenQRCode = true
                }
            
            Text(title)
                .foregroundColor(.gray)
                .scaledFont(size: Device.isLarge ? 20 : 14)
                .padding(.top,10)
                .padding(.bottom,10)
            
            Button(action: {
                PasteboardAlertHelper.shared.copyToPasteBoard(value: self.address, notify: "feedback_addresscopied".localized())
                logger.debug("address copied to clipboard")
         
                tracker.track(.tap(action: .copyAddress), properties: [:])
            }) {
                
               
                HStack{
                    Spacer()
                    Text(self.address)
                        .foregroundColor(.gray)
                        .scaledFont(size: 15)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Image(systemName: "doc.on.doc").foregroundColor(.gray)
                        .scaledFont(size: Device.isLarge ? 20 : 14).padding(.trailing, 10)
                }.padding([.horizontal], 15)
                .frame(minHeight: 50)
               
                /*
                 // Removed the slices instead we would like to display the text in one go
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
                                AddressFragment(number: i + 1, word: self.chips[i])
                                    .frame(height: 24)
                                AddressFragment(number: i + 2, word: self.chips[i+1])
                                    .frame(height: 24)
                            }
                        }
                    }
                    
                }.padding([.horizontal], 15)
                .frame(minHeight: 96)
                 */
            }.alert(item: self.$copyItemModel) { (p) -> Alert in
                PasteboardAlertHelper.alert(for: p)
            }
            .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
                self.copyItemModel = p 
            }
            
            Spacer()
            
            
            GrayButtonView(aTitle: "Request an Amount".localized()).onTapGesture {
                openRequestMoney = true
            }
            
            NavigationLink(
                destination: LazyView(
                    RequestMoneyView(address: self.address,
                                       badge: Image("skullcoin"),
                                       accessoryContent: { EmptyView() })
                        .navigationBarTitle("",displayMode: .inline)
                        .navigationBarHidden(true)
                ), isActive: self.$openRequestMoney
            ) {
                EmptyView()
            }.isDetailLink(false)
            
            Button(action: {
                tracker.track(.tap(action: .receiveScan), properties: [:])
                self.isShareAddressShown = true
            }) {
                BlueButtonView(aTitle: "Share".localized())
            }
        }
        .bottomSheet(isPresented: $openFullScreenQRCode,
                      height: 400,
                      topBarHeight: 0,
                      topBarCornerRadius: 20,
                      showTopIndicator: true) {
            FullScreenImageView(qrImage: Binding.constant(qrImage))
        }
        .padding(10)
        .padding(.bottom,10)
            .sheet(isPresented: self.$isShareAddressShown) {
                ShareSheet(activityItems: [self.address])
            }
    }
}
//
//struct DisplayAddress_Previews: PreviewProvider {
//    static var previews: some View {
//        DisplayAddress(address: "zs1t2scx025jsy04mqyc4x0fsyspxe86gf3t6gyfhh9qdzq2a789sc2eccslflawf2kpuvxcqfjsef")
//    }
//}



struct QRCodeBackgroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
        .padding()
    }
}

