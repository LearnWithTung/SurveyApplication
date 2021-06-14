//
//  AuthFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit

public final class AuthFlow: Flow {
    private let navController: UINavigationController
    private let delegate: LoginViewControllerDelegate
    
    public init(navController: UINavigationController,
         delegate: LoginViewControllerDelegate) {
        self.navController = navController
        self.delegate = delegate
    }
    
    public func start() {
        let vc = LoginUIComposer.loginComposedWith(delegate: delegate)
        
        navController.setViewControllers([vc], animated: true)
    }
    
    public func didLoginWithError(_ message: String) {
        displayError(message: message)
    }
    
    private func displayError(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(action)
            self.navController.present(alertController, animated: true)
        }
    }
    
}
