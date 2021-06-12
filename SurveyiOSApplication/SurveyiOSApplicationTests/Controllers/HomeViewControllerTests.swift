//
//  HomeViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 11/06/2021.
//

import XCTest
import SurveyiOSApplication

class HomeViewControllerTests: XCTestCase {
    
    func test_load_requestsLoadSurveys() {
        let (sut, delegate) = makeSUT()
        
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 0, "Expected no request upon creation")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 1, "Expected request load on view did load")
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(delegate.requestLoadSurveysCallCount, 2, "Expected another request load on pull to refrseh")
    }
    
    func test_loadingView_visibleWhileLoading() {
        let (sut, delegate) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isLoadingViewVisible, "Expected loading view visible on view did load")
        
        delegate.completeLoadingSurveySuccess(with: [])
        XCTAssertFalse(sut.isLoadingViewVisible, "Expected loading view invisible on loading complete")
        
        sut.simulatePullToRefresh()
        XCTAssertTrue(sut.isLoadingViewVisible, "Expected loading view visible on pull to refresh")
        
        delegate.completeLoadingSurveySuccess(with: [])
        XCTAssertFalse(sut.isLoadingViewVisible, "Expected loading view invisible on refresh complete")
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
