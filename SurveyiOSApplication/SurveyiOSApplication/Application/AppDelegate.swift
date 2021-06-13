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
    
    var window: UIWindow?
    var flow: Flow!
    var navigationController: UINavigationController!
    var compositionRoot: CompositionRoot!
    
    override init() {
        guard let baseURL = Configurations.baseURL else {return}
        let authConfig: AuthConfig = getConfig(fromPlist: "AuthConfig")

        compositionRoot = CompositionRoot(baseURL: baseURL, credentials: authConfig.toCredentials)
        (navigationController, flow) = compositionRoot.compose()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        flow.start()
        
        return true
    }
}

extension AuthConfig {
    var toCredentials: Credentials {
        return Credentials(client_id: client_id, client_secret: client_secret)
    }
}
