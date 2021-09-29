//
//  TransactionDetailsTitle.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 20/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit

struct TransactionDetailsTitle: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    
    var status: DetailModel.Status
    
    var available: some View {
        HStack{
           Text(format(zec: availableZec < 0 ? -availableZec : availableZec))
                .foregroundColor(.white)
                .scaledFont(size: 40)
           Text(" \(arrr) ")
                .scaledFont(size: 15)
                .foregroundColor(.zAmberGradient1)
        }
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR".localized() //TODO: handle this weird stuff
    }
    
    var aTitle: String {

        switch status {
        case .paid:
            return "You Sent".localized()
        case .received:
            return "You Received".localized()
        }
    }
    
    var anImage: String {

        switch status {
        case .paid:
            return "wallet_history_sent"
        case .received:
            return "wallet_history_receive"
        }
    }
       
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(aTitle)
                .foregroundColor(.zLightGray)
                .scaledFont(size: 28)
                .padding(.leading,10)
            HStack{
                available.multilineTextAlignment(.leading)
                    .padding(.leading,10)
                Spacer()
                Text("")
                    .scaledFont(size: 12)
                    .foregroundColor(.gray).multilineTextAlignment(.trailing)
                
                Image(anImage).resizable().frame(width:60,height:60).multilineTextAlignment(.trailing)
            }
           
        }
    }
    
    var arrr: String {
        return "ARRR"
    }
}

struct TransactionDetailsTitle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ZcashBackground()
            VStack(alignment: .center, spacing: 50) {
                TransactionDetailsTitle(availableZec: 2.0011,status: DetailModel.Status.received)
            }
        }
    }
}
