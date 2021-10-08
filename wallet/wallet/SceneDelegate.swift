//
//  SceneDelegate.swift
//  wallet
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import UIKit
import SwiftUI
import BackgroundTasks
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        // This is the use case of handling the URL Contexts - Deep linking when app is running in the background
        
        logger.info("Opened up a deep link - App running in the background")
        
        if let url = URLContexts.first?.url {
            let urlDataDict:[String: URL] = ["url": url]

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                logger.info("Opened up a deep link - App is not running in the background")
                NotificationCenter.default.post(name: .openTransactionScreen, object: nil, userInfo: urlDataDict)
            }
        }
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        addSwiftLayout(scene: scene)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("MoveToFirstViewLayout"), object: nil, queue: .main) { (_) in            
            self.addSwiftLayout(scene: scene)
        }
        
        if let url = connectionOptions.urlContexts.first?.url {
            let urlDataDict:[String: URL] = ["url": url]
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                logger.info("Opened up a deep link - App is not running in the background")
                NotificationCenter.default.post(name: .openTransactionScreen, object: nil, userInfo: urlDataDict)
            }
             
        }
    }
    
    func addSwiftLayout(scene: UIScene){
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            #if targetEnvironment(simulator)
            if ProcessInfo.processInfo.environment["isTest"] != nil {
                window.rootViewController = HostingController(rootView:
                        AnyView(
                            NavigationView {
                                Text("test")
                            }
                        )
                ,ignoreSafeArea: true)
                self.window = window
                _zECCWalletNavigationBarLookTweaks()
                window.makeKeyAndVisible()
                return
            }
            #endif
            window.rootViewController = HostingController(rootView:
                    AnyView(
                        NavigationView {
                            TheNoScreen().environmentObject(ZECCWalletEnvironment.shared)
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                        }
                    )
            ,ignoreSafeArea: true)
            self.window = window
            _zECCWalletNavigationBarLookTweaks()
            window.makeKeyAndVisible()
            
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        #if !targetEnvironment(simulator)
        //FIXME: disable background tasks for the time being 
//        BackgroundTaskSyncronizing.default.scheduleAppRefresh()
//        BackgroundTaskSyncronizing.default.scheduleBackgroundProcessing()
        #endif
    }
    
    static var shared: SceneDelegate {
        UIApplication.shared.windows[0].windowScene?.delegate as! SceneDelegate
    }
  
}
