//
//  TransactionDetails.swift
//  MemoTextViewTest
//
//  Created by Francisco Gindre on 8/18/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
import AlertToast

struct TransactionDetails: View {
        
    enum Alerts {
        case explorerNotice
        case copiedItem(item: PasteboardItemModel)
    }
    var detail: DetailModel
    @State var expandMemo = false
    @Environment(\.presentationMode) var presentationMode
    @State var alertItem: Alerts?
    @State var isCopyAlertShown = false
    @State var mURLString:URL?
    @State var mOpenSafari = false

    var exploreButton: some View {
        Button(action: {
            self.alertItem = .explorerNotice
        }) {
            HStack {
                Spacer()
                Text("Explore".localized())
                    .foregroundColor(.white)
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(height: 48)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(.white)
        )
    }
    
    func converDateToString(aDate:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: aDate)
    }
    
    var aTitle: String {

        switch detail.status {
        case .paid(_):
            return  "To: ".localized()
        case .received:
            return "From: ".localized()
        }
    }
    
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 30) {
                VStack {
                    
                    TransactionDetailsTitle(
                        availableZec: detail.arrrAmount,status:detail.status)
                    
                    VStack(alignment: .center, spacing: 10) {
                        Spacer(minLength: 5)
                        ScrollView {
                            VStack {

                                if let fullAddr = detail.arrrAddress{
                                    TransactionRow(mTitle: aTitle, mSubTitle: fullAddr, showLine: true, isYellowColor: false)
                                }else{
                                    TransactionRow(mTitle: aTitle, mSubTitle: (detail.arrrAddress ?? "NA"), showLine: true,isYellowColor: false)
                                }
                                
                                TransactionRowTitleSubtitle(mTitle: converDateToString(aDate: detail.date), mSubTitle: ("Processing fee: ".localized() + "\(detail.defaultFee.asHumanReadableZecBalance().toZecAmount())" + " ARRR"), showLine: true)
                                
                                TransactionRowTitleSubtitle(mTitle: "Memo".localized(), mSubTitle: (detail.memo ?? "-"), showLine: true)
                                
                                if detail.success {
                                    let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
                                    TransactionRow(mTitle: detail.makeStatusText(latestHeight: latestHeight),mSubTitle :"", showLine: false,isYellowColor: true)
                                } else {
                                    TransactionRow(mTitle: "Pending".localized(),mSubTitle :"", showLine: false,isYellowColor: true)
                                }
                                

                            }
                            .modifier(SettingsSectionBackgroundModifier())
                            
                        }
                        
                        Spacer()
                        Spacer()
                        
                        if detail.isMined {// If it is mined or confirmed then only show explore button
                                Button {
                                    self.alertItem = .explorerNotice
                                } label: {
                                    BlueButtonView(aTitle: "Explore".localized())
                                }
                        }

                    }
                    
//                    HeaderFooterFactory.header(for: detail)
//                    SubwayPathBuilder.buildSubway(detail: detail, expandMemo: self.$expandMemo)
//                        .padding(.leading, 32)
//                        .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
//                            self.alertItem = .copiedItem(item: p)
//                        }
//                    HeaderFooterFactory.footer(for: detail)
                    
                }
                
//                if detail.isMined {
//                    exploreButton
//                }
            }
            .onDisappear() {
                NotificationCenter.default.removeObserver(NSNotification.Name("CopyToClipboard"))
            }
            .onAppear() {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("CopyToClipboard"), object: nil, queue: .main) { (_) in
                    isCopyAlertShown = true
                }
            }
            .padding()
        }
        .toast(isPresenting: $isCopyAlertShown){
            
            AlertToast(displayMode:  .hud, type: .regular, title:"Address Copied to clipboard!".localized())

        }
        .padding(.vertical,0)
        .padding(.horizontal, 8)
        .sheet(isPresented: $mOpenSafari) {
            CustomSafariView(url:self.mURLString!)
        }
        .alert(item: self.$alertItem) { item -> Alert in
            switch item {
            case .copiedItem(let p):
                return PasteboardAlertHelper.alert(for: p)
            case .explorerNotice:
                return Alert(title: Text("You are exiting your wallet".localized()),
                             message: Text("While usually an acceptable risk, you are possibly exposing your behavior and interest in this transaction by going online. OH NO! What will you do?".localized()),
                             primaryButton: .cancel(Text("NEVERMIND".localized())),
                             secondaryButton: .default(Text("SEE TX".localized()), action: {
                                
                                guard let url = UrlHandler.blockExplorerURL(for: self.detail.id) else {
                                    return
                                }
                    
                                self.mURLString  = url
                                mOpenSafari = true
                                
//                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                             }))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background(ARRRBackground().edgesIgnoringSafeArea(.all))
    }
}

extension DetailModel {
    var defaultFee: Int64 {
        ZcashSDK.defaultFee(for: self.minedHeight > 0 ? self.minedHeight : (self.expirationHeight > 0 ? self.expirationHeight : BlockHeight.max))
    }
}
struct SubwayPathBuilder {
    static func buildSubway(detail: DetailModel, expandMemo: Binding<Bool>) -> some View {
        var views = [AnyView]()
        
        if detail.isOutbound {
            views.append(
                Text("\(detail.defaultFee.asHumanReadableZecBalance()) " + "network fee".localized())
                    .font(.body)
                    .foregroundColor(.gray)
                    .eraseToAnyView()
            )
        }
        
        if detail.isOutbound {
            views.append(
                Text("from your shielded wallet".localized())
                    .font(.body)
                    .foregroundColor(.gray)
                    .eraseToAnyView()
            )
        } else {
            views.append(
                Text("to your shielded wallet".localized())
                    .font(.body)
                    .foregroundColor(.gray)
                    .eraseToAnyView()
            )
            
        }
        
        if let memo = detail.memo {
            views.append(
                Button(action: {
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: memo, notify: "feedback_addresscopied".localized())
                }) {
                    WithAMemoView(expanded: expandMemo, memo: detail.memo ?? "")
                    
                }
                    .eraseToAnyView()
            )
            
            if let validReplyToAddress = memo.extractValidAddress() {
                views.append(
                    Button(action: {
                        PasteboardAlertHelper.shared.copyToPasteBoard(value: validReplyToAddress, notify: "feedback_addresscopied".localized())
                        tracker.track(.tap(action: .copyAddress), properties: [:])
                    }) {
                        Text("includes reply-to")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .eraseToAnyView()
                )
            }
        }
        
        if let fullAddr = detail.arrrAddress, let toAddr = fullAddr.shortARRRaddress {
            views.append(
                
                Button(action:{
                    PasteboardAlertHelper.shared.copyToPasteBoard(value: fullAddr, notify: "feedback_addresscopied".localized())
                }){
                    (Text("to ")
                        .font(.body)
                        .foregroundColor(.white) +
                        Text(toAddr)
                        .font(.body)
                        .foregroundColor(.gray))
                }
                .eraseToAnyView()
            )
        }
        
        if detail.success {
            let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
            let isConfirmed = detail.isConfirmed(latestHeight: latestHeight)
            views.append(
                Text(detail.makeStatusText(latestHeight: latestHeight))
                    .font(.body)
                    .foregroundColor(isConfirmed ?  detail.shielded ? .zYellow : .zTransparentBlue : .zGray2)
                    .eraseToAnyView()
            )
        } else {
            views.append(
                Text("failed!".localized())
                    .font(.body)
                    .foregroundColor(.red)
                    .eraseToAnyView()
            )
        }
        return DetailListing(details: views)
    }
}



extension DetailModel {
    
    func makeStatusText(latestHeight: Int) -> String {
        guard !self.isConfirmed(latestHeight: latestHeight) else {
            return "Confirmed".localized()
        }
        
        guard minedHeight > 0, latestHeight > 0 else {
            return "Pending confirmation".localized()
        }
        
        return "\(abs(latestHeight - minedHeight)) \("of 10 Confirmations".localized())"
    }
    
    func isConfirmed(latestHeight: Int) -> Bool {
        guard self.isMined, latestHeight > 0 else { return false }
        
        return abs(latestHeight - self.minedHeight) >= 10
        
    }
    
    var isMined: Bool {
        self.minedHeight.isMined
    }
    
    var success: Bool {
        switch self.status {
        case .paid(let success):
            return success
        default:
            return true
        }
    }
    
    var isOutbound: Bool {
        switch self.status {
        case .paid:
            return true
        default:
            return false
        }
    }
}


fileprivate func formatAmount(_ amount: Double) -> String {
    abs(amount).toZecAmount()
}

extension HeaderFooterFactory {
    static func header(for detail: DetailModel) -> some View {
        detail.success ?
            Self.successHeaderWithValue(detail.arrrAmount,
                                        shielded: detail.shielded,
                                        sent: detail.isOutbound,
                                        formatValue: formatAmount) :
            Self.failedHeaderWithValue(detail.arrrAmount,
                                       shielded: detail.shielded,
                                       formatValue: formatAmount)
    }
    // adds network fee on successful transactions
    static func footer(for detail: DetailModel) -> some View {
        detail.success ? Self.successFooterWithValue(detail.isOutbound ? detail.arrrAmount.addingZcashNetworkFee() : detail.arrrAmount,
                                                     shielded: detail.shielded,
                                                     sent: detail.isOutbound,
                                                     formatValue: formatAmount) :
            self.failedFooterWithValue(detail.arrrAmount,
                                       shielded: detail.shielded,
                                       formatValue: formatAmount)
    }
}

func formatDateDetail(_ date: Date) -> String {
    date.transactionDetailFormat()
}

//struct TransactionDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            ZcashBackground()
//            TransactionDetails(detail: DetailModel(id: "fasdfasdf", date: Date(), arrrAmount: 4.32, status: .received, subtitle: "fasdfasd"))
//        }
//    }
//}


extension TransactionDetails.Alerts: Identifiable {
    var id: Int {
        switch self {
        case .copiedItem(_):
            return 1
        default:
            return 2
        }
    }
}



struct TransactionRow: View {
    
    var mTitle:String
    
    var mSubTitle:String
    
    var showLine = false
    
    var isYellowColor = false
    
    var body: some View {

        VStack {
            HStack{
                Text(mTitle+mSubTitle).scaledFont(size: 18).foregroundColor(isYellowColor ? Color.zARRRTextColor : Color.textTitleColor)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding(10)
                Spacer()
                Spacer()
                if !isYellowColor && !mSubTitle.isEmpty && mSubTitle != "NA"{
                    Image(systemName: "doc.on.doc").foregroundColor(.gray)
                        .scaledFont(size: 20).padding(.trailing, 10)
                }
                
            } .onTapGesture {
                if !isYellowColor && !mSubTitle.isEmpty && mSubTitle != "NA"{
                    copyToClipBoard(mSubTitle)
                }
            }
            
            if showLine {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale).padding(10)
            }
        }
    }
   
    func copyToClipBoard(_ content: String) {
        UIPasteboard.general.string = content
        logger.debug("content copied to clipboard")
        NotificationCenter.default.post(name: NSNotification.Name("CopyToClipboard"), object: nil)
    }
}

struct TransactionRowTitleSubtitle: View {
    
    var mTitle:String
    
    var mSubTitle:String
    
    var showLine = false
    
    var body: some View {

        VStack {
            HStack{
                Text(mTitle).font(.barlowRegular(size: 18)).foregroundColor(Color.white)
                                .frame(height: 22,alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                Spacer()
                Spacer()
            }
            
            HStack{
                Text(mSubTitle).font(.barlowRegular(size: 14)).foregroundColor(Color.textTitleColor)
                                .frame(height: 22,alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                Spacer()
                Spacer()
            }
            
            if showLine {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            }
        }.padding(10)
    }
}
