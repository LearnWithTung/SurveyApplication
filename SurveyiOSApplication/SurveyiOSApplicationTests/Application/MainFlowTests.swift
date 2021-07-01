//
//  MainFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import UIKit
import SurveyiOSApplication
import SurveyFramework

class MainFlowTests: XCTestCase {
    
    func test_init_doesNotStart() {
        let (_, nc, _) = makeSUT()
        
        XCTAssertEqual(nc.messages, [])
    }
    
    func test_start_setsViewController() {
        let (sut, nc, _) = makeSUT()

        sut.start()
        
        XCTAssertEqual(nc.messages.count, 1)
        XCTAssertEqual(nc.messages[0].viewControllers?.count, 1)
        XCTAssertEqual(nc.messages[0].animated, true)

        let homeViewController = getHomeViewController(from: nc)

        XCTAssertNotNil(homeViewController)
    }
    
    func test_start_dispatchToMainThreadFromBackgroundThread() {
        let (sut, _, _) = makeSUT()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            sut.start()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_logout_clearsCache() {
        let (sut, nc, store) = makeSUT()

        sut.start()

        let homeViewController = getHomeViewController(from: nc)
        
        homeViewController?.onLogoutRequest?()
        
        XCTAssertEqual(store.requestCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: Flow, navigationController: NavigationControllerSpy, store: TokenCleanerSpy) {
        let navigationControllerSpy = NavigationControllerSpy()
        let delegateSpy = HomeViewControllerDelegateSpy()
        let fakeImageLoader = FakeImageDataLoader()
        let store = TokenCleanerSpy()
        let sut: Flow = MainFlow(navController: navigationControllerSpy, delegate: delegateSpy, store: store, imageLoader: fakeImageLoader, currentDate: Date.init)
        let decorator = MainQueueDispatchDecorator(decoratee: sut)

        checkForMemoryLeaks(fakeImageLoader, file: file, line: line)
        checkForMemoryLeaks(delegateSpy, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(navigationControllerSpy, file: file, line: line)
        checkForMemoryLeaks(decorator, file: file, line: line)

        return (decorator, navigationControllerSpy, store)
    }
    
    private class TokenCleanerSpy: TokenCleaner {
        var requestCallCount: Int = 0
        func clear() {
            requestCallCount += 1
        }
    }
    
    private func getHomeViewController(from navigationController: NavigationControllerSpy) -> HomeViewController? {
        let rootVc = navigationController.messages[0].viewControllers?.first
        rootVc?.loadViewIfNeeded()
        
        return rootVc as? HomeViewController
    }
    
}
