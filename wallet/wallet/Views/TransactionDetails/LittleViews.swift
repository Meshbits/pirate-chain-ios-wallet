//
//  LittleViews.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/18/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct DateAndHeight: View {
    var date: Date
    var formatterBlock: (Date) -> String
    var height: Int
    
    var body: some View {
        HStack {
            Text(self.formatterBlock(date))
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
            if height > 0 {
                Text("from ".localized())
                .font(.body)
                .foregroundColor(.gray) +
                Text("block".localized() + " \(height)")
                .font(.body)
                .foregroundColor(.zGray2)
            }
        }
    }
}
struct WithAMemoView: View {
    @Binding var expanded: Bool
    var memo: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // TODO: move this elsewhere once the subway map is in place
            Button (action: {
                withAnimation {
                    self.expanded.toggle()
                }
            }
            ) {
                HStack {
                    Text("with a".localized())
                        .font(.body)
                        .foregroundColor(.gray)
                    Image("memo_icon")
                    Text("memo".localized())
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
            if expanded && !memo.isEmpty {
                Text(memo)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.zGray2)
                    .layoutPriority(Double.infinity)
                
            }
        }
    }
}

struct LittleViews_Previews: PreviewProvider {
    @State static var expand = false
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack {
                DetailListing(details: [
                    Text("+0.0001 network fee")
                        .font(.body)
                        .foregroundColor(.gray)
                        .eraseToAnyView(),
                    Text("from your shielded wallet")
                        .font(.body)
                        .foregroundColor(.gray)
                        .eraseToAnyView(),
                    WithAMemoView(expanded: .constant(expand), memo: "This is for lunch - Thanks for meeting me such last minute. BOOM!")
                        .eraseToAnyView(),
                    
                        (Text("to ")
                            .font(.body)
                            .foregroundColor(.white) +
                        Text("zs17mg40levj...y3kmwuz8k55a")
                        .font(.body)
                        .foregroundColor(.gray))
                        .eraseToAnyView()
                    .eraseToAnyView(),
                    Text("Confirmed")
                        .font(.body)
                        .foregroundColor(.gray)
                        .eraseToAnyView()
                    
                ])
                Button(action: {
                    //                    withAnimation {
                    expand.toggle()
                    //                    }
                }) {
                    Text("expand memo")
                }
            }
            
        }
        
    }
}
