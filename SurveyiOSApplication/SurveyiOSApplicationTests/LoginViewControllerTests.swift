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
        
        sut.emailTextField.text = "not an email"
        sut.passwordTextField.text = ""
        sut.loginButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on invalid email format and empty password")
        
        sut.emailTextField.text = "tungvuduc2805@gmail.com"
        sut.passwordTextField.text = ""
        sut.loginButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on valid email format and empty password")
        
        sut.emailTextField.text = ""
        sut.passwordTextField.text = "123456789"
        sut.loginButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on empty email and non-empty password")
        
        sut.emailTextField.text = ""
        sut.passwordTextField.text = ""
        sut.loginButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(delegate.requestLoginCallCount, 0, "does not request login on both empty email and password")
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
    }
    
}
