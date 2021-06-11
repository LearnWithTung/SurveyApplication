//
//  AppDelegate.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let delegate = Delegate()
        window?.rootViewController = LoginUIComposer.loginComposedWith(delegate: delegate)
        
        return true
    }
}

private class Delegate: LoginViewControllerDelegate {
    func login() {
        
    }
}

