//
//  AppDelegate.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit
import SurveyFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var credentials: Credentials {
        let authConfig: AuthConfig = getConfig(fromPlist: "AuthConfig")
        return authConfig.toCredentials
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
}

extension AuthConfig {
    var toCredentials: Credentials {
        return Credentials(client_id: client_id, client_secret: client_secret)
    }
}
