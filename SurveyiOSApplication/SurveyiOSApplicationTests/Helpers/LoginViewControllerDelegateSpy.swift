//
//  LoginViewControllerDelegateSpy.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 14/06/2021.
//

import Foundation
import SurveyiOSApplication

class LoginViewControllerDelegateSpy: LoginViewControllerDelegate {
    private var completions = [() -> Void]()
    var requestLoginCallCount: Int = 0
    struct Input: Equatable {
        let email: String
        let password: String
    }
    var input: Input?
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        requestLoginCallCount += 1
        input = .init(email: email, password: password)
        completions.append(completion)
    }
    
    func loginComplete(at index: Int = 0) {
        completions[index]()
    }
}
