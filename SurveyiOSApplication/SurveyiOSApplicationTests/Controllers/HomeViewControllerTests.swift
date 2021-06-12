//
//  HomeViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 11/06/2021.
//

import XCTest
import SurveyiOSApplication

class HomeViewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestLoadSurveys() {
        let (_, delegate) = makeSUT()
        
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 0)
    }
    
    func test_viewDidLoad_requestsLoadSurveys() {
        let (sut, delegate) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 1)
    }
    
    func test_refresh_requestsLoadSurveys() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulatePullToRefresh()
        
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 2)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: HomeViewController, delegate: HomeViewControllerDelegateSpy) {
        let delegate = HomeViewControllerDelegateSpy()
        let sut = HomeViewController(delegate: delegate)
        
        return (sut, delegate)
    }
    
    private class HomeViewControllerDelegateSpy: HomeViewControllerDelegate {
        var requestLoadSurveysCallCount: Int = 0
        
        func loadSurvey() {
            requestLoadSurveysCallCount += 1
        }
    }
}

private extension HomeViewController {
    func simulatePullToRefresh() {
        refresh()
    }
}
