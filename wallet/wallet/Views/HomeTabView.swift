//
//  HomeTabView.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 07/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct HomeTabView: View {
    
    enum Tab {
        case home
        case wallet
        case settings
    }
    
    @State private var mSelectedTab: Tab = .home
    
    @State var mOpenPasscodeScreen: Bool

    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    init(openPasscodeScreen:Bool) {
        
        if #available(iOS 15.0, *) {
           let appearance = UITabBarAppearance()
           appearance.configureWithOpaqueBackground()
           appearance.backgroundColor = UIColor.init(Color.arrrBarTintColor)
            UITabBar.appearance().standardAppearance = appearance
        }else{
            UITabBar.appearance().isTranslucent = false
            UITabBar.appearance().barTintColor = UIColor.init(Color.arrrBarTintColor)
        }
        
        self.mOpenPasscodeScreen = openPasscodeScreen
    }
  
    var body: some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            TabView(selection: $mSelectedTab){
                LazyView(
                        Home().navigationBarHidden(true).environmentObject(HomeViewModel()))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image("walleticon").renderingMode(.template)
                        Text("Wallet".localized())
                            .scaledFont(size: 10)
                    }.tag(Tab.home)
                    .environment(\.currentTab, mSelectedTab)
             
                LazyView(WalletDetails(isActive: Binding.constant(true))
                            .navigationBarHidden(true)
                .environmentObject(WalletDetailsViewModel())
                .navigationBarTitle(Text(""), displayMode: .inline))
                    .tabItem {
                        Image("historyicon").renderingMode(.template)
                        Text("History".localized()).scaledFont(size: 10)
                    }
                    .tag(Tab.wallet)
                    .environment(\.currentTab, mSelectedTab)
             
                SettingsScreen() .navigationBarHidden(true).environmentObject(self.appEnvironment)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image("settingsicon").renderingMode(.template)
                        Text("Settings".localized()).scaledFont(size: 10)
                    }
                    .tag(Tab.settings)
                    .environment(\.currentTab, mSelectedTab)
                
            }
            .accentColor(Color.arrrBarAccentColor)
                
            .onAppear(){
                       
                NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil, queue: .main) { (_) in
                    if UIApplication.shared.windows.count > 0 {
                        UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                    }
                }
            }.sheet(isPresented: $mOpenPasscodeScreen){
                LazyView(PasscodeValidationScreen(passcodeViewModel: PasscodeValidationViewModel(), isAuthenticationEnabled: true)).environmentObject(self.appEnvironment)
            }
            
            
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView(openPasscodeScreen: false)
    }
}


struct CurrentTabKey : EnvironmentKey {
    static var defaultValue: HomeTabView.Tab = .home
}

extension EnvironmentValues {
    var currentTab : HomeTabView.Tab{
        get {self[CurrentTabKey.self]}
        set {self[CurrentTabKey.self] = newValue}
    }
}
