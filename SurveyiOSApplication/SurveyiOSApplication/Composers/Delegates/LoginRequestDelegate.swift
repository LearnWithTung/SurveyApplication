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
    public var onSuccess: ((Token) -> Void)?
    public var onError: ((Error) -> Void)?

    public init(service: LoginService) {
        self.service = service
    }
    
    public func login(email: String, password: String, completion: @escaping () -> Void) {
        service.load(with: .init(email: email, password: password)) {[weak self] result in
            guard let self = self else {return}
            completion()
            switch result {
            case let .success(token):
                self.onSuccess?(token)
            case let .failure(error):
                self.onError?(error)
            }
        }
    }
    
}
