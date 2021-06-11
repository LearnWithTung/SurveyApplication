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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoginViewController, delegate: LoginViewControllerDelegateSpy) {
        let delegate = LoginViewControllerDelegateSpy()
        let sut = LoginUIComposer.loginComposedWith(delegate: delegate)
        checkForMemoryLeaks(delegate, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, delegate)
    }
    
    private func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private class LoginViewControllerDelegateSpy: LoginViewControllerDelegate {
        var requestLoginCallCount: Int = 0
        
        func login() {
            requestLoginCallCount += 1
        }
    }
    
}

private extension LoginViewController {
    
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

private extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
    }
}
