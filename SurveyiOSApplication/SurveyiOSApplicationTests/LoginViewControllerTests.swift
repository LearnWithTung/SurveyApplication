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
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LoginViewController, delegate: LoginViewControllerDelegateSpy) {
        let delegate = LoginViewControllerDelegateSpy()
        let sut = LoginUIComposer.loginComposedWith(delegate: delegate)
        
        return (sut, delegate)
    }
    
    private class LoginViewControllerDelegateSpy: LoginViewControllerDelegate {
        var requestLoginCallCount: Int = 0
    }
    
}
