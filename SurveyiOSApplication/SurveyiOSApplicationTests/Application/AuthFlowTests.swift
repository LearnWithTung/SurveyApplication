//
//  AuthFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import UIKit
import SurveyiOSApplication
import SurveyFramework

class AuthFlowTests: XCTestCase {
    
    func test_init_doesNotStart() {
        let (_, _, nc, _) = makeSUT()
        
        XCTAssertEqual(nc.messages, [])
    }
    
    func test_start_setsViewController() {
        let (sut, _ ,nc, _) = makeSUT()

        sut.start()
        
        XCTAssertEqual(nc.messages.count, 1)
        XCTAssertEqual(nc.messages[0].viewControllers?.count, 1)
        XCTAssertEqual(nc.messages[0].animated, true)

        let loginViewController = getLoginViewController(from: nc)

        XCTAssertNotNil(loginViewController)
    }
    
    func test_start_dispatchToMainThreadFromBackgroundThread() {
        let (sut, _, _, _) = makeSUT()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            sut.start()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loginSuccess_requestsSaveToken() {
        let (_, authFlow, _, store) = makeSUT()

        authFlow.didLoginSuccess(anyNonExpirationToken(currentDate: Date()))
        
        XCTAssertEqual(store.requetsCallCount, 1)
    }
    
    func test_saveNewTokenSuccess_messagesRoot() {
        let (_, authFlow, _, store) = makeSUT()

        var messages = 0
        authFlow.onLoginSuccess = {messages += 1}
        
        authFlow.didLoginSuccess(anyNonExpirationToken(currentDate: Date()))
        store.saveTokenSuccessful()

        XCTAssertEqual(messages, 1)
    }
    
    func test_saveNewTokenFailed_doesNotMessageRoot() {
        let (_, authFlow, _, store) = makeSUT()

        var messages = 0
        authFlow.onLoginSuccess = {messages += 1}
        
        authFlow.didLoginSuccess(anyNonExpirationToken(currentDate: Date()))
        store.saveTokenFailed()

        XCTAssertEqual(messages, 0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: Flow, authFlow: AuthFlow, navigationController: NavigationControllerSpy, store: TokenSaverSpy) {
        let navigationControllerSpy = NavigationControllerSpy()
        let delegate = LoginViewControllerDelegateSpy()
        let store = TokenSaverSpy()
        let sut: Flow = AuthFlow(navController: navigationControllerSpy, delegate: delegate, store: store)
        let decorator = MainQueueDispatchDecorator(decoratee: sut)
        
        checkForMemoryLeaks(navigationControllerSpy, file: file, line: line)
        checkForMemoryLeaks(decorator, file: file, line: line)
        checkForMemoryLeaks(delegate, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)

        return (decorator, sut as! AuthFlow, navigationControllerSpy, store)
    }
    
    private class TokenSaverSpy: TokenSaver {
        var requetsCallCount: Int = 0
        private var completions = [(TokenSaverResult) -> Void]()
        
        func save(token: Token, completion: @escaping (TokenSaverResult) -> Void) {
            requetsCallCount += 1
            completions.append(completion)
        }
        
        func saveTokenSuccessful(at index: Int = 0) {
            completions[index](.success(()))
        }
        
        func saveTokenFailed(at index: Int = 0){
            completions[index](.failure(anyNSError()))
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
