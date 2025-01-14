//
//  BalanceDetailView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 16/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct BalanceDetailView: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    var status: BalanceStatus
    
    var available: some View {
        HStack{
            Text(format(zec: availableZec))
                .foregroundColor(.white)
                .scaledFont(size: 30)
                
            Text(" \(zec) ")
                .scaledFont(size: 20)
                .foregroundColor(.zAmberGradient1)
        }
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR".localized() //TODO: handle this weird stuff
    }
    var includeCaption: Bool {
        switch status {
        case .available(_):
            return false
        default:
            return true
        }
    }
    var caption: some View {
        switch status {
        case .expecting(let zec):
            return  Text("(\("expecting".localized()) ")
                           .font(.body)
                           .foregroundColor(Color.zLightGray) +
            Text("+" + format(zec: zec))
                           .font(.body)
                .foregroundColor(.white)
            + Text(" \(zec))")
                .font(.body)
                .foregroundColor(Color.zLightGray)
        
        case .waiting(let change):
            return  Text("(\("expecting".localized()) ")
                                      .font(.body)
                                    .foregroundColor(Color.zLightGray) +
                       Text("+" + format(zec: change))
                                      .font(.body)
                           .foregroundColor(.white)
                       + Text(" \(zec))")
                           .font(.body)
                           .foregroundColor(Color.zLightGray)
            default:
                return Text("")
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Balance".localized())
                .foregroundColor(.zLightGray)
                .scaledFont(size: 18)
                .padding(.leading,10)
            HStack{
                available.multilineTextAlignment(.leading)
                    .padding(.leading,10)
                Spacer()
                Text("")
                    .scaledFont(size: 12)
                    .foregroundColor(.gray).multilineTextAlignment(.trailing)
            }
            if includeCaption {
                caption
            }
        }
    }
    
    var zec: String {
        if ZcashSDK.isMainnet {
            return "ARRR"
        } else {
            return "TAZ"
        }
    }
}

struct BalanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 50) {
                BalanceDetailView(availableZec: 2.0011,status: .available(showCaption: true))
                BalanceDetailView(availableZec: 0.0011,status: .expecting(zec: 2))
                BalanceDetailView(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}
