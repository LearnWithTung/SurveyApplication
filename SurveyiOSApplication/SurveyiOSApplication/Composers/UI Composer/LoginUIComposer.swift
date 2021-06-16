//
//  LoginUIComposer.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public final class LoginUIComposer {
    private init() {}
    
    public static func loginComposedWith(delegate: LoginViewControllerDelegate) -> LoginViewController {
        let bundle = Bundle(for: LoginViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let loginViewController: LoginViewController = storyboard.instantiate()
        loginViewController.delegate = delegate
        
        return loginViewController
    }
    
}
