//
//  LoginRequestDelegate.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyFramework

public final class LoginRequestDelegate: LoginViewControllerDelegate {
    private let service: LoginService
    private let onSuccess: (Token) -> Void
    private let onError: (Error) -> Void

    public init(service: LoginService, onSuccess: @escaping (Token) -> Void, onError: @escaping (Error) -> Void) {
        self.service = service
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    public func login(email: String, password: String) {
        service.load(with: .init(email: email, password: password)) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(token):
                self.onSuccess(token)
            case let .failure(error):
                self.onError(error)
            }
        }
    }
    
}
