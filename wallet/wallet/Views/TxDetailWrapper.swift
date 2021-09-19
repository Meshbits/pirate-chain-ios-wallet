//
//  TxDetailWrapper.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 1/6/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI


struct TxDetailsWrapper: View {
    @State var row: DetailModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 0) {
                TransactionDetails(detail: row)
                    .zcashNavigationBar(leadingItem: {
                       EmptyView()
                    }, headerItem: {
                        HStack{
                            Text("Transaction Details".localized())
                                .font(.barlowRegular(size: 26)).foregroundColor(Color.zSettingsSectionHeader)
                                .frame(alignment: Alignment.center)
                        }
                    }, trailingItem: {
                        ARRRCloseButton(action: {
                            presentationMode.wrappedValue.dismiss()
                            }).frame(width: 30, height: 30)
                    })
            }
            .padding(.top, 20)
        }
    }
}
