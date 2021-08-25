//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
struct ReceiveFunds: View {
    
    let unifiedAddress: UnifiedAddress
    @Environment(\.presentationMode) var presentationMode
    @State var selectedTab: Int = 0
    var body: some View {
        NavigationView {
            
            ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 10, content: {
                    DisplayAddress(address: unifiedAddress.zAddress,
                                   title: "address_shielded".localized(),
                                   badge: Image("skullcoin"),
                                   accessoryContent: { EmptyView() })
                })
            }.zcashNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                     Text("receive_title")
                         .font(.barlowRegular(size: 26)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center).padding(.top,20)
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     presentationMode.wrappedValue.dismiss()
                     }).frame(width: 30, height: 30).padding(.top,20)
             })
            .onAppear {
                tracker.track(.screen(screen: .receive), properties: [:])
            }
            .navigationBarHidden(true)
//            .navigationBarTitle(Text("receive_title"),
//                                           displayMode: .inline)                       
//                       .navigationBarItems(trailing: ZcashCloseButton(action: {
//                           tracker.track(.tap(action: .receiveBack), properties: [:])
//                           presentationMode.wrappedValue.dismiss()
//                           }).frame(width: 30, height: 30))
        }
    }
}
