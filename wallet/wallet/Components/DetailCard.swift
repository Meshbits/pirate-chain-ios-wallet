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
    var arrrAddress: String?
    var date: Date
    var arrrAmount: Double
    var status: Status
    var shielded: Bool = true
    var memo: String? = nil
    var minedHeight: Int = -1
    var expirationHeight: Int = -1
    var title: String {

        switch status {
        case .paid(let success):
            return success ? "You paid \(arrrAddress?.shortARRRaddress ?? "Unknown")" : "Unsent Transaction"
        case .received:
            return "\(arrrAddress?.shortARRRaddress ?? "Unknown") paid you"
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
    var backgroundColor: Color = Color.init(red: 0.13, green: 0.14, blue: 0.15)
        
    var zecAmount: some View {
        let amount = model.arrrAmount.toZecAmount()
        var text = ((model.arrrAmount > 0 && model.arrrAmount >= 0.001) ? "+" : "") + ((model.arrrAmount < 0.001 && model.arrrAmount > 0) ? "< 0.001" : amount)
        var color = Color.zARRRReceivedColor
        var opacity = Double(1)
        switch model.status {
        case .paid(let success):
            color = Color.zARRRSentColor //success ? Color.zARRRSentColor : Color.zLightGray2
            opacity = success ? 1 : 0.6
            
//            text = success ? text : "(\(text) ARRR)"
            
        default:
            break
        }
        
        
        return
            Text(text)
                .foregroundColor(color)
                .opacity(opacity).font(.barlowRegular(size: 18))
            
    }
    
    var body: some View {
        ZStack {
            HStack {
                Image.statusImage(for: model.status).resizable().frame(width: 20, height: 20, alignment: .center)

                VStack(alignment: .leading){
                    HStack {
//                        Text(model.title)
                        Text(model.date.aFormattedDate)
                            .font(.barlowRegular(size: 20))
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .layoutPriority(0.5)

                    }
                    Text(String.transactionSubTitle(for: model))
                        .font(.body)
                        .truncationMode(.tail)
                        .foregroundColor(.zARRRSubtitleColor)
                        .opacity(0.6)
                }
                .padding(.vertical, 8)
                Spacer()
                zecAmount
                    .padding(.trailing,10)
               
            }
            
        }.cornerRadius(5)
        
    }
    
}

extension Image {
    static func statusImage(for cardType: DetailModel.Status) -> Image {
        var imageName = "gray_shield"
        switch cardType {
    
        case .paid(let success):
            imageName = success ? "senticon" : "gray_shield"
        case .received:
            imageName = "receiveicon"
        }
        
        return Image(imageName)
    }
}

extension String {
    static func transactionSubTitle(for model: DetailModel) -> String {
        var transactionSubTitle = "Pending"
        switch model.status {
    
        case .paid(let success):
            transactionSubTitle = (success ? "sent via " : "sent via ") + (model.arrrAddress ?? "NA") // TODO: need to check what should we show in case a transaction is sent but is in pending state
        case .received:
            transactionSubTitle = "received via "
        }
        
        transactionSubTitle = transactionSubTitle + (model.arrrAddress ?? "NA")
        
        return transactionSubTitle
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
                            arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                            date: Date(),
                            arrrAmount: -12.345,
                            status: .paid(success: true),
                            subtitle: "1 of 10 confirmations"
                            )
                    )
                    .padding()
            
            
            DetailCard(model:
            DetailModel(
                id: "bb032",
                    arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    arrrAmount: 2.0,
                    status: .received,
                    subtitle: "Received 11/16/19 4:12pm"
                    )
            )
            
            DetailCard(model:
            DetailModel(
                id: "bb033",
                    arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                    date: Date(),
                    arrrAmount: 2.0,
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
        self.arrrAddress = confirmedTransaction.toAddress
        self.arrrAmount = (sent ? -Int64(confirmedTransaction.value) : Int64(confirmedTransaction.value)).asHumanReadableZecBalance()
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
        self.shielded = pendingTransaction.toAddress.isValidShieldedAddress
        self.status = .paid(success: submitSuccess)
        self.expirationHeight = pendingTransaction.expiryHeight
        self.subtitle = DetailModel.subtitle(isPending: isPending,
                                             isSubmitSuccess: submitSuccess,
                                             minedHeight: pendingTransaction.minedHeight,
                                             date: self.date.transactionDetail,
                                             latestBlockHeight: latestBlockHeight)
        self.arrrAddress = pendingTransaction.toAddress
        self.arrrAmount = -Int64(pendingTransaction.value).asHumanReadableZecBalance()
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
    

extension Date {
    var aFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: self)
    }
}
