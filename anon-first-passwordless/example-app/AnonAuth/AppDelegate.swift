//
//  AppDelegate.swift
//  AnonAuth
//
//  Created by Michael Neas on 7/7/20.
//  Copyright © 2020 neas.lease.anonauth. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        /// preliminary check
        if Auth.auth().currentUser != nil {
            // User is signed in.
            print("User signed in")
            Auth.auth().currentUser?.isAnonymous
        } else {
            // No user is signed in.
            print("NO User signed in")
            // check if in intermediary state
            var handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                if user == nil {
                    print("Signing in anonymously")
                    Auth.auth().signInAnonymously { (authResult, error) in
                        guard let user = authResult?.user else { return }
                        let isAnonymous = user.isAnonymous  // true
                        let uid = user.uid
                        //self.vm.login(user: Auth.auth().currentUser)
                        print(uid)
                    }
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

