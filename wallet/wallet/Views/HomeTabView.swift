//
//  HomeTabView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 07/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct HomeTabView: View {
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    init() {
            UITabBar.appearance().isTranslucent = false
            UITabBar.appearance().barTintColor = UIColor.init(Color.arrrBarTintColor)
        }
  
    var body: some View {
        ZStack {
            ARRRBackground()
            TabView {
                LazyView(
                        Home().environmentObject(HomeViewModel()))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image("walleticon").renderingMode(.template)
                        Text("Wallet").font(.barlowRegular(size: 10))
                    }
             
                LazyView(WalletDetails(isActive: Binding.constant(true))
                .environmentObject(WalletDetailsViewModel())
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarHidden(true))
                    .tabItem {
                        Image("historyicon").renderingMode(.template)
                        Text("History").font(.barlowRegular(size: 10))
                    }
             
                SettingsScreen().environmentObject(self.appEnvironment).navigationBarHidden(true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image("settingsicon").renderingMode(.template)
                        Text("Settings").font(.barlowRegular(size: 10))
                    }
            }.accentColor(Color.arrrBarAccentColor)
            .onAppear(){
                       
                NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil, queue: .main) { (_) in
                    if UIApplication.shared.windows.count > 0 {
                        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                    }
                }
            }
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
