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
    
    func test_load_displaysLoadingViewWhileLoading() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isLoadingViewVisible)
    }
    
    func test_load_hidesLoadingViewOnComplete() {
        let (sut, delegate) = makeSUT()
        sut.loadViewIfNeeded()
        
        delegate.completeLoadingSurveySuccess(with: [])
        
        XCTAssertFalse(sut.isLoadingViewVisible)
    }
    
    func test_refresh_displaysLoadingViewWhileRefreshing() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulatePullToRefresh()
        
        XCTAssertTrue(sut.isLoadingViewVisible)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: HomeViewController, delegate: HomeViewControllerDelegateSpy) {
        let delegate = HomeViewControllerDelegateSpy()
        let sut = HomeViewController(delegate: delegate)
        checkForMemoryLeaks(delegate, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
    
    private class HomeViewControllerDelegateSpy: HomeViewControllerDelegate {
        var requestLoadSurveysCallCount: Int = 0
        private var completions = [(Result<[RepresentationSurvey], Error>) -> Void]()
        
        func loadSurvey(completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
            requestLoadSurveysCallCount += 1
            completions.append(completion)
        }
        
        func completeLoadingSurveySuccess(with surveys: [RepresentationSurvey], at index: Int = 0) {
            completions[index](.success(surveys))
        }
        
    }
}

private extension HomeViewController {
    func simulatePullToRefresh() {
        refresh()
    }
    
    var isLoadingViewVisible: Bool {
        return !loadingView.isHidden
    }
}
