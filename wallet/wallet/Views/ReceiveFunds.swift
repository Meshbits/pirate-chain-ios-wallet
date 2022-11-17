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
    enum Tabs: Int, Equatable {
        case unified
        case sapling
        case transparent
    }
    let unifiedAddress: UnifiedAddress
    @Environment(\.presentationMode) var presentationMode
    @State var selectedTab: Int = Tabs.unified.rawValue
    var body: some View {
        NavigationView {
            
            ZStack {
                ZcashBackground()
                VStack(alignment: .center, spacing: 10, content: {
                    TabSelector(tabs: [
                        (Text("Unified")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, idealHeight: 48)
                         ,.green),
                        (Text("Sapling")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, idealHeight: 48)
                         ,.zYellow),
                        (Text("Transparent")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity, minHeight: 48, idealHeight: 48)
                         ,.zTransparentBlue)
                            
                    ], selectedTabIndex: $selectedTab)
                    .padding([.horizontal], 16)

                    switch Tabs(rawValue: selectedTab) {
                    case .unified, .none:
                        DisplayAddress(
                            address: unifiedAddress.stringEncoded,
                            title: "address_unified".localized(),
                            badge: Image("QR-zcashlogo"),
                            accessoryContent: {
                                HStack(alignment: .center) {
                                    Image("yellow_shield")
                                    VStack(alignment: .leading) {
                                        Text("Contains Shielded and Transparent receivers")
                                            .lineLimit(nil)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                        Text("Any transparent funds received will be auto-shielded.")
                                            .lineLimit(nil)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        )
                    case .sapling:
                        DisplayAddress(
                            address: unifiedAddress.saplingReceiver()!.stringEncoded,
                            title: "address_sapling".localized(),
                            chips: 8,
                            badge: Image("QR-zcashlogo"),
                            accessoryContent: { EmptyView() }
                        )
                    case .transparent:
                        DisplayAddress(
                            address: unifiedAddress.transparentReceiver()!.stringEncoded,
                            title: "address_transparent".localized(),
                            chips: 2,
                            badge: Image("t-zcash-badge"),
                            accessoryContent: {
                                VStack(alignment: .leading) {
                                    Text("This address is for receiving only.")
                                        .lineLimit(nil)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                    Text("Any funds received will be auto-shielded.")
                                        .lineLimit(nil)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                            }
                        )
                    }
                })
            }
            .onAppear {
                tracker.track(.screen(screen: .receive), properties: [:])
            }
            .navigationBarTitle(Text("receive_title"),
                                displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing: ZcashCloseButton(action: {
                tracker.track(.tap(action: .receiveBack), properties: [:])
                presentationMode.wrappedValue.dismiss()
                }).frame(width: 30, height: 30))
        }
    }
}
