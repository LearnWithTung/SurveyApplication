//
//  UIExtension+TestHelpers.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit
import SurveyiOSApplication

extension LoginViewController {
    
    func setEmailText(_ text: String) {
        emailTextField.text = text
    }
    
    func setPasswordText(_ text: String) {
        passwordTextField.text = text
    }
    
    func simulateLoginButtonTap() {
        loginButton.simulateTap()
    }
    
}

extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
    }
}
