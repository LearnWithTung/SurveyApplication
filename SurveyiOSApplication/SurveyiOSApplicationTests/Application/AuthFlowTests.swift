//
//  AuthFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import UIKit

class AuthFlow {
    private let navController: UINavigationController
    
    init(navController: UINavigationController) {
        self.navController = navController
    }
    
}

class AuthFlowTests: XCTestCase {
    
    func test_init_doesNotStart() {
        let (_, nc) = makeSUT()
        
        XCTAssertEqual(nc.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AuthFlow, navigationController: NavigationControllerSpy) {
        let navigationControllerSpy = NavigationControllerSpy()
        let sut = AuthFlow(navController: navigationControllerSpy)
        
        checkForMemoryLeaks(navigationControllerSpy, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)

        return (sut, navigationControllerSpy)
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
