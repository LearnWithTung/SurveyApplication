//
//  AuthFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import UIKit
import SurveyiOSApplication

class AuthFlowTests: XCTestCase {
    
    func test_init_doesNotStart() {
        let (_, nc) = makeSUT()
        
        XCTAssertEqual(nc.messages, [])
    }
    
    func test_start_setsViewController() {
        let (sut, nc) = makeSUT()

        sut.start()
        
        XCTAssertEqual(nc.messages.count, 1)
        XCTAssertEqual(nc.messages[0].viewControllers?.count, 1)
        XCTAssertEqual(nc.messages[0].animated, true)

        let loginViewController = getLoginViewController(from: nc)

        XCTAssertNotNil(loginViewController)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AuthFlow, navigationController: NavigationControllerSpy) {
        let navigationControllerSpy = NavigationControllerSpy()
        let delegate = DelegateSpy()
        let sut = AuthFlow(navController: navigationControllerSpy, delegate: delegate)
        
        checkForMemoryLeaks(navigationControllerSpy, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(delegate, file: file, line: line)

        return (sut, navigationControllerSpy)
    }
    
    private class DelegateSpy: LoginViewControllerDelegate {
        func login(email: String, password: String) {
            
        }
    }
    
    private func getLoginViewController(from navigationController: NavigationControllerSpy) -> LoginViewController? {
        let rootVc = navigationController.messages[0].viewControllers?.first
        rootVc?.loadViewIfNeeded()
        
        return rootVc as? LoginViewController
    }
}

final class NavigationControllerSpy: UINavigationController {
    enum Message: Equatable {
        case set(viewControllers: [UIViewController], animated: Bool)
        
        var viewControllers: [UIViewController]? {
            guard case .set(let viewControllers, _) = self else {
                return nil
            }
            
            return viewControllers
        }
        
        var animated: Bool? {
            guard case .set(_, let animated) = self else {
                return nil
            }
            
            return animated
        }
    }
    
    var messages: [Message] = []
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        messages.append(.set(viewControllers: viewControllers, animated: animated))

    }
}
