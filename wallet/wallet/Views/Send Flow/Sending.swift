//
//  Sending.swift
//  wallet
//
//  Created by Francisco Gindre on 1/8/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit

struct Sending: View {
    
    let dragGesture = DragGesture()
    @EnvironmentObject var flow: SendFlowEnvironment
    @State var details: DetailModel? = nil
    @Environment(\.presentationMode) var presentationMode
    var errorMessage: String {
        guard let e = flow.error else {
            return "thing is that we really don't know what just went down, sorry!"
        }
        
        return "\(e)"
    }
 
    var showErrorAlert: Alert {
        var errorMessage = "an error ocurred while submitting your transaction"
        
        if let error = self.flow.error {
            errorMessage = "\(ZECCWalletEnvironment.mapError(error: error) )"
        }
        return Alert(title: Text("Error"),
                     message: Text(errorMessage),
                     dismissButton: .default(
                        Text("button_close"),
                        action: {
                            self.flow.close()
                            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                     }
            )
        )
    }
    
    var sendText: some View {
        guard flow.error == nil else {
            return Text("label_unabletosend".localized())
        }
        
        return flow.isDone ? Text("send_sent".localized()).foregroundColor(.white) :     Text(String(format: NSLocalizedString(ZcashSDK.isMainnet ? "send_sending" : "send_sending_taz", comment: ""), flow.amount)).foregroundColor(.white)
    }
    
    var body: some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                sendText
                    .foregroundColor(.white)
                    .scaledFont(size: 22)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text("\(flow.address)")
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .scaledFont(size: 15)
                
                if !flow.isDone {
                    LottieAnimation(isPlaying: true,
                                    filename: "lottie_sending",
                                    animationType: .circularLoop)
                        .frame(height: 48)
                    
                }
                Spacer()
                if self.flow.isDone && self.flow.pendingTx != nil {
                    Button(action: {
                        guard let pendingTx = self.flow.pendingTx  else {
                            tracker.report(handledException: DeveloperFacingErrors.unexpectedBehavior(message: "Attempt to open transaction details in sending screen with no pending transaction in send flow"))
                            tracker.track(.error(severity: .warning), properties: [ErrorSeverity.messageKey : "Attempt to open transaction details in sending screen with no pending transaction in send flow"])
                            self.flow.close() // close this so it does not get stuck here
                            return
                        }
                        
                        let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
                        self.details = DetailModel(pendingTransaction: pendingTx,latestBlockHeight: latestHeight)
                        tracker.track(.tap(action: .sendFinalDetails), properties: [:])
                        
                    }) {
                        
                        SendRecieveButtonView(title: "button_seedetails".localized(),isSyncing:Binding.constant(false))
                        
                    }
                }
                
                if flow.isDone {
                    Button(action: {
                        tracker.track(.tap(action: .sendFinalClose), properties: [:])
                        self.flow.close()
                        NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                    }) {
                        SendRecieveButtonView(title: "button_done".localized(),isSyncing:Binding.constant(false))
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
        }
        .highPriorityGesture(dragGesture)
        .sheet(item: $details, onDismiss: {
            self.flow.close()
            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
        }){ item in
            TxDetailsWrapper(row: item)
        }
        .alert(isPresented: self.$flow.showError) {
            showErrorAlert
        }
        .onAppear() {
            tracker.track(.screen(screen: .sendFinal), properties: [:])
            self.flow.preSend()
        }
    }
}
