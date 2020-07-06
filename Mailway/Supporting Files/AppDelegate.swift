//
//  AppDelegate.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let appContext = AppContext()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let preferredLanguages = Locale.preferredLanguages

        #if DEBUG
        print("DEBUG mode")
        print("Local.preferredLanguages: \(preferredLanguages)")
        #endif
        
        #if PREVIEW
        print("PREVIEW mode")
        appContext.documentStore.setupPreview(for: appContext.managedObjectContext)
        #endif
        
        return true
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

extension AppDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        #if DEBUG
        return .all
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
        #endif
    }
}

extension AppContext {
    static var shared: AppContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appContext
    }
}
