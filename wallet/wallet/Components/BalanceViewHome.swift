//
//  BalanceViewHome.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 21/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct BalanceViewHome: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    var status: BalanceStatus
    var aTitleStatus: String
    
    
    var available: some View {
        Text(format(zec: availableZec))
            .foregroundColor(.white)
            .font(.barlowRegular(size: Device.isLarge ? 40 : 30))
       + Text(" \(zec) ")
            .font(.barlowRegular(size: Device.isLarge ? 25 : 18))
            .foregroundColor(.zAmberGradient1)
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR" //TODO: handle this weird stuff
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
            Text("Balance")
                .foregroundColor(.zLightGray)
                .font(.barlowRegular(size: Device.isLarge ? 22 : 14))
                .padding(.leading,10)
            HStack{
                available.multilineTextAlignment(.leading)
                    .padding(.leading,10)
                Spacer()
                Text(aTitleStatus)
                     .font(.barlowRegular(size: Device.isLarge ? 22 : 14))
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

struct BalanceViewHome_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 50) {
//                BalanceViewHome(availableZec: 2.0011,status: .available(showCaption: true))
//                BalanceViewHome(availableZec: 0.0011,status: .expecting(zec: 2))
//                BalanceViewHome(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}