//
//  Home.swift
//  wallet
//
//  Created by Francisco Gindre on 1/2/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var sendZecAmount: Double
    @Published var showReceiveFunds: Bool
    @Published var showProfile: Bool
    @Published var verifiedBalance: Double
    @Published var isSyncing: Bool = false
    @Published var sendingPushed: Bool = false
    @Published var zAddress = ""
    @Published var balance: Double = 0
    @Published var progress: Float = 0
    private var cancellable = [AnyCancellable]()
    init(amount: Double = 0, balance: Double = 0) {
        verifiedBalance = balance
        sendZecAmount = amount
        showProfile = false
        showReceiveFunds = false
        if let environment = SceneDelegate.shared.environment {
            cancellable.append(
                environment.synchronizer.verifiedBalance.subscribe(on: DispatchQueue.main)
                    .sink(receiveValue: { self.verifiedBalance = $0 })
            )
            cancellable.append(environment.synchronizer.balance.subscribe(on: DispatchQueue.main)
                .sink(receiveValue: { self.balance = $0 }))
            cancellable.append(environment.synchronizer.progress.subscribe(on: DispatchQueue.main)
                .sink(receiveValue: { self.progress = $0 }))
            zAddress = environment.initializer.getAddress() ?? ""
        }
    }
}

struct Home: View {
    
    var keypad: KeyPad
    @ObservedObject var viewModel: HomeViewModel
    
    var isSendingEnabled: Bool {
        $viewModel.verifiedBalance.wrappedValue > 0
    }
    var disposables: Set<AnyCancellable> = []
    
    init(amount: Double, verifiedBalance: Double) {
        self.viewModel = HomeViewModel(amount: amount, balance: verifiedBalance)
        self.keypad = KeyPad()
        
        self.keypad.viewModel.$value.receive(on: DispatchQueue.main)
            .assign(to: \.sendZecAmount, on: viewModel)
            .store(in: &disposables)
    }
    
    var syncingButton: some View {
        Button(action: {}) {
            Text("Syncing")
                
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.zAmberGradient2, lineWidth: 4)
            )
        }
    }
    
    var enterAddressButton: some View {
        ZcashButton(color: Color.black, fill: Color.zYellow, text: "Enter Address")
            .frame(height: 58)
            .padding([.leading, .trailing], 40)
            .opacity(isAmountValid ? 1.0 : 0.3 ) // validate this
            .disabled(!isAmountValid)
        
    }
    
    var isAmountValid: Bool {
        self.$viewModel.sendZecAmount.wrappedValue > 0 && self.$viewModel.sendZecAmount.wrappedValue < self.$viewModel.verifiedBalance.wrappedValue
        
    }
    
    var body: some View {
        ZStack {
            
            if self.isSendingEnabled {
                ZcashBackground(showGradient: self.isSendingEnabled)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .center) {
                Spacer()
                SendZecView(zatoshi: self.$viewModel.sendZecAmount)
                    .opacity(self.isSendingEnabled ? 1.0 : 1.0)
                    .scaledToFit()
                
                if self.isSendingEnabled {
                    Spacer()
                    BalanceDetail(availableZec: self.$viewModel.verifiedBalance.wrappedValue, status: .available)
                } else {
                    Spacer()
                    ActionableMessage(message: "No Balance", actionText: "Fund Now", action: {})
                        .padding()
                }
                Spacer()
                self.keypad
                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
                    .disabled(self.$viewModel.verifiedBalance.wrappedValue <= 0)
                    .padding()
                    .frame(minWidth: 0, maxWidth: 250, alignment: .center)
                    
                
                
                Spacer()
                
                if self.$viewModel.isSyncing.wrappedValue {
                    self.syncingButton
                } else {
                    NavigationLink(
                        destination: EnterRecipient().environmentObject(
                            SendFlowEnvironment(
                                amount: self.viewModel.sendZecAmount,
                                verifiedBalance: self.viewModel.verifiedBalance
                            )
                        )
                    ) {
                        self.enterAddressButton
                    }.disabled(!self.isAmountValid)
                }
                
                Spacer()
                
                
                NavigationLink(destination: WalletDetails(balance: self.viewModel.verifiedBalance, zAddress: self.viewModel.zAddress, status: BalanceStatus.waiting(change: 0.304), items: DetailModel.mockDetails)
                    .navigationBarTitle(Text(""), displayMode: .inline)) {
                        HStack(alignment: .center, spacing: 10) {
                            Image("wallet_details_icon")
                            Text("Wallet Details")
                                .font(.headline)
                                .frame(height: 48)
                        }.accentColor(Color.zLightGray)
                }
                Spacer()
                
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    self.viewModel.showReceiveFunds = true
                }) {
                    Image("QRCodeIcon")
                        .accessibility(label: Text("Receive Funds"))
                        .scaleEffect(0.5)
                }
                .sheet(isPresented: $viewModel.showReceiveFunds){
                    ReceiveFunds(address: self.viewModel.zAddress)
                        .navigationBarHidden(true)
                        .navigationBarTitle("", displayMode: .inline)
                }
                , trailing:
                Button(action: {
                    self.viewModel.showProfile = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .imageScale(.large)
                        .opacity(0.6)
                        .accessibility(label: Text("Your Profile"))
                        .padding()
            })
            .sheet(isPresented: $viewModel.showProfile){
                ProfileScreen(zAddress: self.$viewModel.zAddress)
            }
        
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(try! ZECCWalletEnvironment())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(try! ZECCWalletEnvironment())
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
            
            Home(amount: 1.2345, verifiedBalance: 1.2345).environmentObject(try! ZECCWalletEnvironment())
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
                .previewDisplayName("iPhone 11")
        }
    }
}