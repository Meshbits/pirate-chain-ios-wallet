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
            UITabBar.appearance().barTintColor = UIColor.init(Color.init(red: 0.13, green: 0.14, blue: 0.15))
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
             
                SettingsScreen().navigationBarHidden(true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image("settingsicon").renderingMode(.template)
                        Text("Settings").font(.barlowRegular(size: 10))
                    }
            }.accentColor(Color.init(red: 194.0/255.0, green: 136.0/255.0, blue: 101.0/255.0))
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
