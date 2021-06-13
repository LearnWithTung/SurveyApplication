//
//  MainFlowTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import UIKit
import SurveyiOSApplication

class MainFlowTests: XCTestCase {
    
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

        let homeViewController = getHomeViewController(from: nc)

        XCTAssertNotNil(homeViewController)
    }
    
    func test_start_dispatchToMainThreadFromBackgroundThread() {
        let (sut, _) = makeSUT()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            sut.start()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: Flow, navigationController: NavigationControllerSpy) {
        let navigationControllerSpy = NavigationControllerSpy()
        let delegateSpy = DelegateSpy()
        let fakeImageLoader = FakeImageDataLoader()
        let sut: Flow = MainFlow(navController: navigationControllerSpy, delegate: delegateSpy, imageLoader: fakeImageLoader, currentDate: Date.init, surveyDetailFlow: FlowTests())
        let decorator = MainQueueDispatchDecorator(decoratee: sut)

        checkForMemoryLeaks(fakeImageLoader, file: file, line: line)
        checkForMemoryLeaks(delegateSpy, file: file, line: line)
        checkForMemoryLeaks(navigationControllerSpy, file: file, line: line)
        checkForMemoryLeaks(decorator, file: file, line: line)

        return (decorator, navigationControllerSpy)
    }
    
    private class DelegateSpy: HomeViewControllerDelegate {
        func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {}
    }
    
    private func getHomeViewController(from navigationController: NavigationControllerSpy) -> HomeViewController? {
        let rootVc = navigationController.messages[0].viewControllers?.first
        rootVc?.loadViewIfNeeded()
        
        return rootVc as? HomeViewController
    }
    
}
