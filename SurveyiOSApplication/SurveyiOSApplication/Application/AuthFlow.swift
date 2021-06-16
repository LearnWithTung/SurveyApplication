//
//  AuthFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit
import SurveyFramework

public final class AuthFlow: Flow {
    private let navController: UINavigationController
    private let delegate: LoginViewControllerDelegate
    private let store: TokenSaver
    public var onLoginSuccess: (() -> Void)?
    
    public init(navController: UINavigationController,
         delegate: LoginViewControllerDelegate,
         store: TokenSaver) {
        self.navController = navController
        self.delegate = delegate
        self.store = store
    }
    
    public func start() {
        let vc = LoginUIComposer.viewControllerComposedWith(delegate: delegate)
        
        navController.setViewControllers([vc], animated: true)
    }
    
    public func didLoginWithError(_ message: String) {
        displayError(message: message)
    }
    
    public func didLoginSuccess(_ token: Token) {
        store.save(token: token) {[weak self] result in
            switch result {
            case .success:
                self?.onLoginSuccess?()
            case .failure:
                self?.displayError(message: "Unexpected error. Please try later.")
            }
        }
    }
    
    private func displayError(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(action)
            self?.navController.present(alertController, animated: true)
        }
    }
    
}
