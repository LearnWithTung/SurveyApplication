//
//  LoginRequestDelegateTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyiOSApplication
import SurveyFramework

class LoginRequestDelegate: LoginViewControllerDelegate {
    private let service: LoginService
    private let onSuccess: (Token) -> Void
    
    init(service: LoginService, onSuccess: @escaping (Token) -> Void) {
        self.service = service
        self.onSuccess = onSuccess
    }
    
    func login(email: String, password: String) {
        service.load(with: .init(email: email, password: password)) {[unowned self] result in
            switch result {
            case let .success(token):
                self.onSuccess(token)
            default:
                break
            }
        }
    }
    
}

class LoginRequestDelegateTests: XCTestCase {
    
    func test_login_requetsLoginWithInputValues() {
        let (sut, service) = makeSUT()
        let email = "an email"
        let password = "a password"
        
        sut.login(email: email, password: password)
        
        XCTAssertEqual(service.getRequestedInfo().email, email)
        XCTAssertEqual(service.getRequestedInfo().password, password)
    }
    
    func test_login_delegateMessageWithTokenOnLoginSuccess() {
        let email = "an email"
        let password = "a password"
        
        var capturedTokens = [Token]()
        let (sut, service) = makeSUT { token in
            capturedTokens.append(token)
        }
        
        sut.login(email: email, password: password)
        
        let token = makeTokenWith(expiredDate: Date())
        service.completeSucessful(with: token)
        
        XCTAssertEqual(capturedTokens.count, 1)
        XCTAssertEqual(capturedTokens.first, token)
    }
    
    // MARK: - Helpers
    private func makeSUT(onSucess: @escaping (Token) -> Void = {_ in}, file: StaticString = #file, line: UInt = #line) -> (sut: LoginRequestDelegate, service: LoginServiceSpy) {
        let service = LoginServiceSpy()
        let sut = LoginRequestDelegate(service: service, onSuccess: onSucess)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(service, file: file, line: line)
        
        return (sut, service)
    }
    
    private class LoginServiceSpy: LoginService {
        private var messages = [(info: LoginInfo, completion: (LoginResult) -> Void)]()
        
        func load(with info: LoginInfo, completion: @escaping (LoginResult) -> Void) {
            messages.append((info, completion))
        }
        
        func getRequestedInfo(at index: Int = 0) -> LoginInfo{
            messages[index].info
        }
        
        func completeSucessful(with token: Token, at index: Int = 0) {
            messages[index].completion(.success(token))
        }
    
    }
}
