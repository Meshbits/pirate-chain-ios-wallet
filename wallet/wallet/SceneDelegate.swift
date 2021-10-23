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
import AVFoundation

let mPlaySoundWhileSyncing = "PlaySoundWhenAppEntersBackground"

let mStopSoundOnceFinishedOrInForeground = "StopSoundWhenAppEntersForeground"

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
        
//        Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        UIApplication.shared.isIdleTimerDisabled = true
        
        addSwiftLayout(scene: scene)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("MoveToFirstViewLayout"), object: nil, queue: .main) { (_) in            
            self.addSwiftLayout(scene: scene)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(mPlaySoundWhileSyncing), object: nil, queue: .main) { (_) in
            self.playSoundWhileSyncing()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil, queue: .main) { (_) in
            self.stopSoundIfPlaying()
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
//      Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
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
//        #if !targetEnvironment(simulator)
        //FIXME: disable background tasks for the time being 
//        BackgroundTaskSyncronizing.default.scheduleAppRefresh()
        BackgroundTaskSyncronizing.default.scheduleBackgroundProcessing()
//        #endif
    }
    
    
    
    var mAVAudioPlayerObj : AVAudioPlayer?

    func playSoundWhileSyncing() {
        // Play sound only in background
        if (UIApplication.shared.applicationState == .background){
            if let path = Bundle.main.path(forResource: "bgsound", ofType: "aac") {
                let filePath = NSURL(fileURLWithPath:path)
                mAVAudioPlayerObj = try! AVAudioPlayer.init(contentsOf: filePath as URL)
                mAVAudioPlayerObj?.numberOfLoops = -1 //logic for infinite loop just to make sure it keeps running
                mAVAudioPlayerObj?.prepareToPlay()
                mAVAudioPlayerObj?.volume = 0.05 // Super low volume
                mAVAudioPlayerObj?.play()
            }
            
            showNotificationInNotificationTrayWhileSyncing()

            //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
        }
    }
    
    func stopSoundIfPlaying(){
        // If AVAudio player is playing a song then go ahead and kill it
        if mAVAudioPlayerObj != nil && mAVAudioPlayerObj?.isPlaying == true {
            mAVAudioPlayerObj?.stop()
            showNotificationInNotificationTrayWhileSyncingIsFinished()
        }
        
    }
    
    static var shared: SceneDelegate {
        UIApplication.shared.windows[0].windowScene?.delegate as! SceneDelegate
    }
    
    func showNotificationInNotificationTrayWhileSyncingIsFinished(){
        DispatchQueue.main.async {
            let content = UNUserNotificationCenter.current()
            content.removeAllDeliveredNotifications()
            content.removeAllPendingNotificationRequests()
        }
    }
    
    func showNotificationInNotificationTrayWhileSyncing(){
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Pirate Chain Wallet", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Please keep the app running in the background, while we sync your wallet and keep it up to date. Thank you!",
                                                                    arguments: nil)
            content.sound = UNNotificationSound.default
            
            let date = Date(timeIntervalSinceNow: 3) // Post notification after 3 seconds
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            // Create the request object.
            let request = UNNotificationRequest(identifier: "BackgroundSyncing", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
              center.add(request) { (error) in
           }
        }
    }
  
}
