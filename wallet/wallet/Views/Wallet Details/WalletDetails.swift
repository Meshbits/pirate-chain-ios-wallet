//
//  WalletDetails.swift
//  wallet
//
//  Created by Francisco Gindre on 1/21/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import ZcashLightClientKit
class WalletDetailsViewModel: ObservableObject {
    // look at before changing https://stackoverflow.com/questions/60956270/swiftui-view-not-updating-based-on-observedobject
    @Published var items = [DetailModel]()

    var showError = false
    @Published var balance: WalletBalance = .zero
    var address: UnifiedAddress
    private var synchronizerEvents = Set<AnyCancellable>()
    private var internalEvents = Set<AnyCancellable>()

    init(){
        self.address = ZECCWalletEnvironment.shared.synchronizer.unifiedAddress
        subscribeToSynchonizerEvents()
    }
    
    deinit {
        unsubscribeFromSynchonizerEvents()
    }

    
    func subscribeToSynchonizerEvents() {
        ZECCWalletEnvironment.shared.synchronizer.walletDetailsBuffer
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] (d) in
                self?.items = d
            })
            .store(in: &synchronizerEvents)
        
        ZECCWalletEnvironment.shared.synchronizer.shieldedBalance
            .receive(on: RunLoop.main)
            .assign(to: \.balance, on: self)
            .store(in: &synchronizerEvents)
    }
    
    func unsubscribeFromSynchonizerEvents() {
        synchronizerEvents.forEach { (c) in
            c.cancel()
        }
        synchronizerEvents.removeAll()
    }
}

struct WalletDetails: View {
    @StateObject var viewModel: WalletDetailsViewModel
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @Binding var isActive: Bool
    @State var selectedModel: DetailModel? = nil

    var body: some View {
        
        ZStack {
            ZcashBackground()
            VStack(alignment: .center) {
                ZcashNavigationBar(
                    leadingItem: {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("Back")
                                .renderingMode(.original)
                        }
                        
                    },
                   headerItem: {
                        BalanceDetail(
                            availableZec: $viewModel.balance.wrappedValue.verified.decimalValue.doubleValue,
                            status: balanceStatus($viewModel.balance.wrappedValue))
                            
                    },
                   trailingItem: { EmptyView() }
                )
                .padding(.horizontal, 10)
                

                List {
                    WalletDetailsHeader(zAddress: viewModel.address.stringEncoded)
                        .listRowBackground(Color.zDarkGray2)
                        .frame(height: 100)
                        .padding([.trailing], 24)
                    ForEach(self.viewModel.items, id: \.id) { row in
                       
                        Button(action: {
                            self.selectedModel = row
                        }) {
                            DetailCard(model: row, backgroundColor: .zDarkGray2)
                        }
                        .listRowBackground(Color.zDarkGray2)
                        .frame(height: 69)
                        .padding(.horizontal, 16)
                        .cornerRadius(0)
                        .border(Color.zGray, width: 1)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.zGray, lineWidth: 1.0)
                )
                .padding()
                
            }
        }
        .onAppear() {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = UIColor.clear
            tracker.track(.screen(screen: .history), properties: [:])

        }
        .alert(isPresented: self.$viewModel.showError) {
            Alert(title: Text("Error"),
                  message: Text("an error ocurred"),
                  dismissButton: .default(Text("button_close")))
        }
        .onDisappear() {
            UITableView.appearance().separatorStyle = .singleLine
        }
        .navigationBarHidden(true)
        .sheet(item: self.$selectedModel, onDismiss: {
            self.selectedModel = nil
        }) { (row)  in
            TxDetailsWrapper(row: row)
        }

    }

    func balanceStatus(_ balance: WalletBalance) -> BalanceStatus {
        let status = BalanceStatus.from(shieldedBalance: balance)
        switch status {
        case .available(_):
            return .available(showCaption: false)
        default:
            return status
        }
    }
}

struct WalletDetails_Previews: PreviewProvider {
    static var previews: some View {
        return WalletDetails(viewModel: WalletDetailsViewModel(), isActive: .constant(true))
    }
}

class MockWalletDetailViewModel: WalletDetailsViewModel {
    
    override init() {
        super.init()
        
    }
    
}

extension DetailModel {
    static var mockDetails: [DetailModel] {
        var items =  [DetailModel]()
       
            items.append(contentsOf:
                [
                    
                    DetailModel(
                        id: "bb031",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        amount: Zatoshi(-12_345_000),
                        status: .paid(success: true),
                        subtitle: "1 of 10 confirmations"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb032",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        amount: Zatoshi(2 * Zatoshi.Constants.oneZecInZatoshi),
                        status: .received,
                        subtitle: "Received 11/16/19 4:12pm"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb033",
                        zAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        amount: Zatoshi(2 * Zatoshi.Constants.oneZecInZatoshi),
                        status: .paid(success: false),
                        subtitle: "Received 11/16/19 4:12pm"
                    )
                    
                ]
            )
        
        return items
    }
}
