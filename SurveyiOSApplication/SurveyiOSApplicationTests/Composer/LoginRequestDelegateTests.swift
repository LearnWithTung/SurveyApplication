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
    
    init(service: LoginService) {
        self.service = service
    }
    
    func login(email: String, password: String) {
        service.load(with: .init(email: email, password: password)) { result in
            
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LoginRequestDelegate, service: LoginServiceSpy) {
        let service = LoginServiceSpy()
        let sut = LoginRequestDelegate(service: service)
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
    }
}
