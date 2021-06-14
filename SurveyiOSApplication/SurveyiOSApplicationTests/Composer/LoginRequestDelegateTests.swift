//
//  LoginRequestDelegateTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyiOSApplication
import SurveyFramework


class LoginRequestDelegateTests: XCTestCase {
    
    func test_login_requetsLoginWithInputValues() {
        let (sut, service) = makeSUT()
        let email = "an email"
        let password = "a password"
        
        sut.login(email: email, password: password) {}
        
        XCTAssertEqual(service.getRequestedInfo().email, email)
        XCTAssertEqual(service.getRequestedInfo().password, password)
    }
    
    func test_login_delegateMessageWithTokenOnLoginSuccess() {
        var capturedTokens = [Token]()
        let (sut, service) = makeSUT { token in
            capturedTokens.append(token)
        }
        
        sut.login(email: "an email", password: "a password") {}

        let token = makeTokenWith(expiredDate: Date())
        service.completeSucessful(with: token)
        
        XCTAssertEqual(capturedTokens.count, 1)
        XCTAssertEqual(capturedTokens.first, token)
    }
    
    func test_login_delegateMessageWithErrornOnLoginFailed() {
        var capturedErrors = [Error]()
        let (sut, service) = makeSUT(onError: { error in
            capturedErrors.append(error)
        })
        
        sut.login(email: "an email", password: "a password") {}
        
        let error = anyNSError()
        service.completeWithError(error)
        
        XCTAssertEqual(capturedErrors.count, 1)
        XCTAssertEqual(capturedErrors.first as NSError?, error)
    }
    
    func test_login_doesNotResultAfterSUTInstanceHasBeenDeallocated() {
        let service = LoginServiceSpy()
        var capturedToken: Token?
        var capturedError: Error?
        var sut: LoginRequestDelegate? = LoginRequestDelegate(service: service)
        sut?.onSuccess = {
            capturedToken = $0
        }
        sut?.onError = {
            capturedError = $0
        }
        
        sut?.login(email: "an email", password: "a password") {}
        
        sut = nil
        
        service.completeSucessful(with: makeTokenWith(expiredDate: Date()))
        service.completeWithError(anyNSError())
        
        XCTAssertNil(capturedToken)
        XCTAssertNil(capturedError)
    }
    
    // MARK: - Helpers
    private func makeSUT(onSucess: @escaping (Token) -> Void = {_ in}, onError: @escaping (Error) -> Void = {_ in}, file: StaticString = #file, line: UInt = #line) -> (sut: LoginRequestDelegate, service: LoginServiceSpy) {
        let service = LoginServiceSpy()
        let sut = LoginRequestDelegate(service: service)
        sut.onSuccess = onSucess
        sut.onError = onError
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
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    
    }
}
