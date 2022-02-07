//
//  ECCWalletApp.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 7/5/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

@main
struct ECCWalletApp: App {
//    @StateObject var environment: ZECCWalletEnvironment = ZECCWalletEnvironment.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    
  
    let sceneDelegate = SceneDelegate()
    
    init() {
        _zECCWalletNavigationBarLookTweaks()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                stateForBuild(isTest)
                    .withHostingWindow { window in
                        sceneDelegate.originalDelegate = window?.windowScene?.delegate
                        sceneDelegate.window = window
                        window?.windowScene?.delegate = sceneDelegate
                     }
            }
            .navigationViewStyle(StackNavigationViewStyle())
//            .onChange(of: phase) { newPhase in
//                switch newPhase {
//                case .active:
//                // App became active
//                    logger.debug("App became active")
//                case .inactive:
//                // App became inactive
//                    logger.debug("App became inactive")
//                case .background:
//                // App is running in the background
//                    logger.debug("App is running in the background")
//                @unknown default:
//                // Fallback for future cases
//                    logger.debug("App State defaulted: \(newPhase)")
//                    break
//                }
//            }
        }
    }
    
    
    @ViewBuilder func stateForBuild(_ isTest: Bool) -> some View {
        if isTest {
            Text("Test")
        } else {
            TheNoScreen(appEnvironment: ZECCWalletEnvironment.shared)
        }
    }
    
    var isTest: Bool {
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["isTest"] != nil {
            return true
        }
        #endif
        return false
    }
}

extension View {
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
