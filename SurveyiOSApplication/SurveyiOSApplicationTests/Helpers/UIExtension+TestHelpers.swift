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
    
    var isLoadingViewVisible: Bool {
        !loadingView.isHidden
    }
    
}

extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
    }
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0, userInfo: nil)
}
