//
//  AppDelegate.swift
//  wallet
//
//  Created by Francisco Gindre on 12/26/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import UIKit
import BackgroundTasks
import AVFoundation
import UserNotifications

#if ENABLE_LOGGING
//import Bugsnag
import zealous_logger
let tracker = MixPanelLogger(token: Constants.mixpanelProject)
let logger = SimpleFileLogger(logsDirectory: try! URL.logsDirectory(), alsoPrint: true, level: .debug)
#else
let tracker = NullLogger()
let logger = SimpleLogger(logLevel: .debug)
#endif

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {  
    
    static var isTouchIDVisible = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifier,
          using: nil) { (task) in
            BackgroundTaskSyncronizing.default.handleBackgroundProcessingTask(task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifierARRR,
          using: nil) { (task) in
            
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) { (granted, error) in

              if granted {
                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }
              }

        }
        
        // To support background playing of audio
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        application.isIdleTimerDisabled = true
        
        return true
    }
    
    func clearKeyChainIfAnythingExists(){
        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: "didWeInstallItBefore") == false {

               // removing all keychain items in here
                SeedManager.default.nukeWallet()
               // updating the local flag
               userDefaults.set(true, forKey: "didWeInstallItBefore")
               userDefaults.synchronize() // forces the app to update the NSUserDefaults

               return
           }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
  
}
