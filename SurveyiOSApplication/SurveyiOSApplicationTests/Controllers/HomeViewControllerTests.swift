//
//  HomeViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 11/06/2021.
//

import XCTest
import SurveyiOSApplication

class HomeViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_imageLoaderIsNotNil() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.surveyViewController.imageLoader)
    }
    
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
    
    func test_load_updatesDataSourceOnLoadingCompleteSuccessful() {
        let (sut, delegate) = makeSUT()
        let survey1 = RepresentationSurvey(title: "title 1", description: "description 1", imageURL: URL(string: "https:url-1.com")!)
        let survey2 = RepresentationSurvey(title: "title 1", description: "description 1", imageURL: URL(string: "https:url-1.com")!)
        let survey3 = RepresentationSurvey(title: "title 1", description: "description 1", imageURL: URL(string: "https:url-1.com")!)

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfSurveysRendered(), 0, "Expected no survey rendered on view did load")

        delegate.completeLoadingSurveySuccess(with: [], at: 0)
        XCTAssertEqual(sut.numberOfSurveysRendered(), 0, "Expected no survey rendered when first loading is completed with empty surveys")
        
        sut.simulatePullToRefresh()
        delegate.completeLoadingSurveySuccess(with: [survey1], at: 1)
        XCTAssertEqual(sut.numberOfSurveysRendered(), 1, "Expected surveys rendered when first loading is completed with one surveys")
        
        sut.simulatePullToRefresh()
        delegate.completeLoadingSurveySuccess(with: [survey1, survey2, survey3], at: 2)
        XCTAssertEqual(sut.numberOfSurveysRendered(), 3, " Expected surveys rendered when first loading is completed with three surveys")
    }
    
    func test_load_doesNotAlterCurrentStateOnLoadingFails() {
        let (sut, delegate) = makeSUT()
        let survey1 = RepresentationSurvey(title: "title 1", description: "description 1", imageURL: URL(string: "https:url-1.com")!)
        let survey2 = RepresentationSurvey(title: "title 1", description: "description 1", imageURL: URL(string: "https:url-1.com")!)

        sut.loadViewIfNeeded()
        delegate.completeLoadingSurveySuccess(with: [survey1, survey2], at: 0)
        XCTAssertEqual(sut.numberOfSurveysRendered(), 2, "Expected survey rendered when first loading is completed successful")
        
        sut.simulatePullToRefresh()
        delegate.completeLoadingSurveyWithError(NSError(domain: "test", code: 0, userInfo: nil), at: 1)
        XCTAssertEqual(sut.numberOfSurveysRendered(), 2, "Expected does not alter current state on loading fails")
    }
    
    func test_viewDidLoad_rendersCurrentDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let expectedDate = dateFormatter.string(from: currentDate).uppercased()
        
        let (sut, _) = makeSUT(currentDate: { currentDate })
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedDate(), expectedDate)
    }
    
    func test_loadSurveyCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoadingSurveySuccess(with: [], at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_refresh_receivesRefreshMessage() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulatePullToRefresh()

        XCTAssertEqual(loader.requestLoadSurveysCallCount, 2)
    }
    
    func test_requestsLogout_messageRoot() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        var requestCallCount = 0
        sut.onLogoutRequest = {
            requestCallCount += 1
        }
        
        sut.userInitiatedLogout()
        
        XCTAssertEqual(requestCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: HomeViewController, delegate: HomeViewControllerDelegateSpy) {
        let delegate = HomeViewControllerDelegateSpy()
        let fakeImageLoader = FakeImageDataLoader()
        let sut = HomeUIComposer.homeComposedWith(delegate: delegate, imageLoader: fakeImageLoader, currentDate: currentDate)
        
        checkForMemoryLeaks(fakeImageLoader, file: file, line: line)
        checkForMemoryLeaks(delegate, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}

private extension HomeViewController {
    func simulatePullToRefresh() {
        surveyViewController.onRefresh?()
    }
    
    var isLoadingViewVisible: Bool {
        return !loadingView.isHidden
    }
    
    func numberOfSurveysRendered() -> Int {
        return surveyViewController.surveyModels.count
    }
    
    func renderedDate() -> String? {
        return dateLabel.text
    }
    
    func userInitiatedLogout() {
        self.menuViewController.logoutButton.simulateTap()
    }
}
