//
//  LoginViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 11/06/2021.
//

import XCTest
import SurveyiOSApplication

class LoginViewControllerTests: XCTestCase {
     
    func test_viewDidLoad_doesNotRequestLogin() {
        let (sut, delegate) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(delegate.requestLoginCallCount, 0)
    }
    
    func test_viewDidLoad_hidesLoadingView() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isLoadingViewVisible, false)
    }
    
    func test_login_doesNotDisplayLoadingViewOnInvalidInputValues() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.setEmailText("")
        sut.setPasswordText("")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(sut.isLoadingViewVisible, false)
    }
    
    func test_login_displaysLoadingView() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.setEmailText("tungvuduc2805@gmail.com")
        sut.setPasswordText("123456789")
        sut.simulateLoginButtonTap()
        
        XCTAssertEqual(sut.isLoadingViewVisible, true)
    }
    
    func test_login_hidesLoadingViewOnLoginRequestCompletion() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.setEmailText("tungvuduc2805@gmail.com")
        sut.setPasswordText("123456789")
        sut.simulateLoginButtonTap()
        
        delegate.loginComplete()
        
        XCTAssertEqual(sut.isLoadingViewVisible, false)
    }
    
    func test_login_doesNotRequestLoginOnInvalidInputValues() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.setEmailText("not an email")
        sut.setPasswordText("")
        sut.simulateLoginButtonTap()
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on invalid email format and empty password")
        
        sut.setEmailText("tungvuduc2805@gmail.com")
        sut.setPasswordText("")
        sut.simulateLoginButtonTap()
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on valid email format and empty password")
        
        sut.setEmailText("")
        sut.setPasswordText("123456789")
        sut.simulateLoginButtonTap()
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on empty email and non-empty password")
        
        sut.setEmailText("")
        sut.setPasswordText("")
        sut.simulateLoginButtonTap()
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on both empty email and password")
    }
    
    func test_login_requestsLoginOnValidInputValue() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.setEmailText("tungvuduc2805@gmail.com")
        sut.setPasswordText("123456789")
        sut.simulateLoginButtonTap()

        XCTAssertEqual(delegate.requestLoginCallCount, 1)
    }
    
    func test_login_requestsLoginWithInput() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        let email = "tungvuduc2805@gmail.com"
        let password = "123456789"
        
        sut.setEmailText(email)
        sut.setPasswordText(password)
        sut.simulateLoginButtonTap()

        XCTAssertEqual(delegate.input, .init(email: email, password: password))
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoginViewController, delegate: LoginViewControllerDelegateSpy) {
        let delegate = LoginViewControllerDelegateSpy()
        let sut = LoginUIComposer.viewControllerComposedWith(delegate: delegate)
        checkForMemoryLeaks(delegate, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, delegate)
    }
    
    
    
}


