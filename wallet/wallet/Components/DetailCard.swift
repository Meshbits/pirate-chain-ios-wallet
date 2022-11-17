//
//  DetailCard.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct DetailModel: Identifiable {
    
    enum Status {
        case paid(success: Bool)
        case received
    }
    var id: String
    var zAddress: String?
    var date: Date
    var amount: Zatoshi
    var status: Status
    var shielded: Bool = true
    var memo: String? = nil
    var minedHeight: Int = -1
    var expirationHeight: Int = -1
    var title: String {

        switch status {
        case .paid(let success):
            return success ? "You paid \(zAddress?.shortZaddress ?? "Unknown")" : "Unsent Transaction"
        case .received:
            return "\(zAddress?.shortZaddress ?? "Unknown") paid you"
        }
    }
    
    var subtitle: String
    
}

extension DetailModel: Equatable {
    static func == (lhs: DetailModel, rhs: DetailModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct DetailCard: View {
 
    var model: DetailModel
    var backgroundColor: Color = .black
    
    @ViewBuilder var shieldImage: some View {
        if case .paid(let success) = model.status, success {
            Image("ic_shieldtick").renderingMode(.original)
        } else {
            EmptyView()
        }
    }
    
    var zecAmount: some View {
        let amount = model.amount.amount
        var text = ((amount > 0 && amount >= 10000) ? "+ " : "") + ((amount < 10000 && amount > 0) ? "< 0.001" : model.amount.decimalString())
        var color = Color.zPositiveZecAmount
        var opacity = Double(1)
        switch model.status {
        case .paid(let success):
            color = success ? Color.zNegativeZecAmount : Color.zLightGray2
            opacity = success ? 1 : 0.6
            
            text = success ? text : "(\(text) ZEC)"
            
        default:
            break
        }
        
        
        return
            Text(text)
                .foregroundColor(color)
                .opacity(opacity)
            
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            HStack {
                StatusLine(status: model.status)
                    .frame(width: 3.0)
                    .padding(.vertical, 8)

                VStack(alignment: .leading){
                    HStack {
                        shieldImage
                        Text(model.title)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .layoutPriority(0.5)

                    }
                    Text(model.subtitle)
                        .font(.body)
                        .foregroundColor(.zLightGray2)
                        .opacity(0.6)
                }
                .padding(.vertical, 8)
                Spacer()
                zecAmount
               
            }
            
        }.cornerRadius(5)
        
    }
    
}

struct StatusLine: View {
    var status: DetailModel.Status = .paid(success: true)
    
    var opacity: Double {
        var _opacity = Double(1)
        switch status {
        case .paid(let success):
            if !success {
                _opacity = 0.6
            }
        default:
            break
        }
        return _opacity
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            Capsule(style: .circular)
                .size(geometry.size)
                .fill(
                    LinearGradient.gradient(for: self.status)
                )
                .opacity(self.opacity)
        }
    }
}

extension LinearGradient {
    static func gradient(for cardType: DetailModel.Status) -> LinearGradient {
        var gradient = Gradient.paidCard
        switch cardType {
    
        case .paid(let success):
            gradient = success ? Gradient.paidCard : Gradient.failedCard
        case .received:
            gradient = Gradient.receivedCard
        }
        return LinearGradient(
            gradient: gradient,
            startPoint: UnitPoint(x: 0.3, y: 0.7),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}


struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
                DetailCard(model:
                    DetailModel(
                        id: "bb031",
                            zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                            date: Date(),
                            amount: Zatoshi(12_345_000),
                            status: .paid(success: true),
                            subtitle: "1 of 10 confirmations"
                            )
                    )
                    .padding()
            
            
            DetailCard(model:
            DetailModel(
                id: "bb032",
                    zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    amount: Zatoshi(2 * Zatoshi.Constants.oneZecInZatoshi),
                    status: .received,
                    subtitle: "Received 11/16/19 4:12pm"
                    )
            )
            
            DetailCard(model:
            DetailModel(
                id: "bb033",
                    zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    amount: Zatoshi(2 * Zatoshi.Constants.oneZecInZatoshi),
                    status: .paid(success: false),
                    subtitle: "Received 11/16/19 4:12pm"
                    )
            )
        }.previewLayout(.fixed(width: 360, height: 69))
    }
}


import ZcashLightClientKit
extension Date {
    var transactionDetail: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy h:mm a"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
extension DetailModel {

    init(confirmedTransaction: ConfirmedTransactionEntity, sent: Bool = false) {
        self.date = Date(timeIntervalSince1970: confirmedTransaction.blockTimeInSeconds)
        self.id = confirmedTransaction.transactionEntity.transactionId.toHexStringTxId()
        self.shielded = confirmedTransaction.toAddress?.isValidShieldedAddress ?? true
        self.status = sent ? .paid(success: confirmedTransaction.minedHeight > 0) : .received
        self.subtitle = sent ? "wallet_history_sent".localized() + " \(self.date.transactionDetail)" : "Received".localized() + " \(self.date.transactionDetail)"
        self.zAddress = confirmedTransaction.toAddress
        self.amount = sent ? -confirmedTransaction.value : confirmedTransaction.value
        if let memo = confirmedTransaction.memo {
            self.memo = memo.asZcashTransactionMemo()
        }
        self.minedHeight = confirmedTransaction.minedHeight
    }

    init(pendingTransaction: PendingTransactionEntity, latestBlockHeight: BlockHeight? = nil) {
        let submitSuccess = pendingTransaction.isSubmitSuccess
        let isPending = pendingTransaction.isPending(currentHeight: latestBlockHeight ?? -1)
        
        self.date = Date(timeIntervalSince1970: pendingTransaction.createTime)
        self.id = pendingTransaction.rawTransactionId?.toHexStringTxId() ?? String(pendingTransaction.createTime)
        self.shielded = pendingTransaction.recipient.isShielded
        self.status = .paid(success: submitSuccess)
        self.expirationHeight = pendingTransaction.expiryHeight
        self.subtitle = DetailModel.subtitle(isPending: isPending,
                                             isSubmitSuccess: submitSuccess,
                                             minedHeight: pendingTransaction.minedHeight,
                                             date: self.date.transactionDetail,
                                             latestBlockHeight: latestBlockHeight
        )
        self.zAddress = pendingTransaction.recipient.stringEncodedAddress
        self.amount = -pendingTransaction.value
        if let memo = pendingTransaction.memo {
            self.memo = memo.asZcashTransactionMemo()
        }
        self.minedHeight = pendingTransaction.minedHeight
    }
}



extension DetailModel {
    var isSubmitSuccess: Bool {
        switch status {
        case .paid(let s):
            return s
        default:
            return false
        }
    }
    
    static func subtitle(isPending: Bool, isSubmitSuccess: Bool, minedHeight: BlockHeight, date: String, latestBlockHeight: BlockHeight?) -> String {
        
        guard isPending else {
            return "\("wallet_history_sent".localized()) \(date)"
        }
        
        guard minedHeight > 0, let latestHeight = latestBlockHeight, latestHeight > 0 else {
            return "Pending confirmation".localized()
        }
        
        return "\(abs(latestHeight - minedHeight)) \("of 10 Confirmations".localized())"
    }
}
    
extension Zatoshi {
    static prefix func -(_ zatoshi: Self) -> Self {
        Zatoshi(-zatoshi.amount)
    }
}

extension PendingTransactionRecipient {
    var isShielded: Bool {
        switch self {
        case .address(let recipient):
            switch recipient {
            case .sapling, .unified:
                return true
            case .transparent:
                return false
            }
        case .internalAccount:
            return true
        }
    }

    var stringEncodedAddress: String {
        switch self {
        case .address(let recipient):
            switch recipient {
            case .sapling(let saplingAddress):
                return saplingAddress.stringEncoded.shortAddress
            case .transparent(let transparentAddress):
                return transparentAddress.stringEncoded.shortAddress
            case .unified(let unified):
                return unified.stringEncoded.shortAddress
            }
        case .internalAccount(let account):
            return "Funds shielded account \(account)"
        }
    }
}
