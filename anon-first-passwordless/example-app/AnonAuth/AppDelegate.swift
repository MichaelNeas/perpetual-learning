//
//  AppDelegate.swift
//  AnonAuth
//
//  Created by Michael Neas on 11/22/20.
//  Copyright © 2020 neas.lease.anonauth. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO: Set up your own GoogleService-Info.plist and place it in the anon auth directory
        // Override point for customization after application launch.
        FirebaseApp.configure()
        /// preliminary check will fire whenever authentication state changes
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("Current user signed in is \(user.uid)")
                print("Current user is anonymous? \(user.isAnonymous)")
            } else {
                print("Signing in anonymously")
                Auth.auth().signInAnonymously { (authResult, error) in
                    guard let user = authResult?.user else { return }
                    print("Anonymous? \(user.isAnonymous)")
                    print("UID: \(user.uid)")
                }
            }
        }
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

