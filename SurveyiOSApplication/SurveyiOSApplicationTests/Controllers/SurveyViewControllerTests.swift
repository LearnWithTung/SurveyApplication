//
//  SurveyViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 12/06/2021.
//

import XCTest
@testable import SurveyiOSApplication

class SurveyViewControllerTests: XCTestCase {
    
    func test_updateDataSource_resetsToEmptyViews() {
        let (sut, _) = makeSUT()

        sut.surveyModels = []
        
        XCTAssertEqual(sut.backgroundImageView.image, nil)
        XCTAssertEqual(sut.descriptionLabel.text, nil)
        XCTAssertEqual(sut.titleLabel.text, nil)
        XCTAssertEqual(sut.pageControl.numberOfPages, 0)
        XCTAssertEqual(sut.pageControl.currentPage, 0)
    }
    
    func test_renders_firstViewOnNonEmptyDataSource() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1]
        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
        
        sut.surveyModels = [survey2]
        XCTAssertEqual(sut.titleLabel.text, survey2.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey2.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
        
        sut.surveyModels = [survey1, survey2]
        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 2)
    }
    
    func test_userInitiatedNextView_rendersNextModel() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        
        sut.simulateMoveNext()
        
        XCTAssertEqual(sut.titleLabel.text, survey2.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey2.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 2)
        XCTAssertEqual(sut.pageControl.currentPage, 1)
        XCTAssertEqual(sut.backgroundImageView.image, nil)
    }
    
    func test_userInitiatedNextView_doesNotRenderNextModelOnAtEdge() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        
        sut.surveyModels = [survey1]
        
        sut.simulateMoveNext()
        
        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
        XCTAssertEqual(sut.pageControl.currentPage, 0)
    }
    
    func test_userInitiatedPreviousView_rendersPreviousModel() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        
        sut.simulateMoveNext()
        sut.simulateMovePrevious()

        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 2)
        XCTAssertEqual(sut.pageControl.currentPage, 0)
    }
    
    func test_userInitiatedPreviousView_doesNotRenderPreviousModelOnAtEdge() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        
        sut.surveyModels = [survey1]
        
        sut.simulateMovePrevious()

        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
        XCTAssertEqual(sut.pageControl.currentPage, 0)
    }
    
    func test_updateDataSource_resetCurrentIndex() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
                
        sut.surveyModels = [survey1, survey2]
        XCTAssertEqual(sut.currentIndex, 0)
        
        sut.simulateMoveNext()
        XCTAssertEqual(sut.currentIndex, 1)

        sut.surveyModels = [survey1]
        XCTAssertEqual(sut.currentIndex, 0)
    }
    
    func test_loadImageData_requestsLoadFirstImageOnNonEmptyDataSource() {
        let (sut, loader) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1]
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL])
        
        sut.surveyModels = [survey1]
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL, survey1.imageURL])
        
        sut.surveyModels = [survey2]
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL, survey1.imageURL, survey2.imageURL])
        
        sut.surveyModels = []
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL, survey1.imageURL, survey2.imageURL])
    }
    
    func test_userInitiatedMove_requestsLoadImage() {
        let (sut, loader) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL])
        
        sut.simulateMoveNext()
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL, survey2.imageURL])
        
        sut.simulateMovePrevious()
        XCTAssertEqual(loader.loadedURLs, [survey1.imageURL, survey2.imageURL, survey1.imageURL])
    }
    
    func test_loadImageView_rendersLoadedImage() {
        let (sut, loader) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        
        sut.surveyModels = [survey1]
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.loadImageCompleteSuccessWith(data: imageData)
        
        XCTAssertEqual(sut.renderedImageData(), imageData)
    }
    
    func test_loadImageView_cancelsLoadOnUpdateDataSource() {
        let (sut, loader) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1]
        XCTAssertEqual(loader.cancelledURLs, [])
        
        sut.surveyModels = [survey2]
        XCTAssertEqual(loader.cancelledURLs, [survey1.imageURL])
    }
    
    func test_loadImageView_cancelsLoadOnUserInitiatedMove() {
        let (sut, loader) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        XCTAssertEqual(loader.cancelledURLs, [])
        
        sut.simulateMoveNext()
        XCTAssertEqual(loader.cancelledURLs, [survey1.imageURL])
    }
    
    func test_userInitiatedReload_requestsReloadData() {
        let (sut, _) = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)

        var refreshCallCount: Int = 0
        sut.onRefresh = {
            refreshCallCount += 1
        }
        
        sut.surveyModels = []
        sut.simulateMovePrevious()
        XCTAssertEqual(refreshCallCount, 1)
        
        sut.surveyModels = [survey1]
        sut.simulateMovePrevious()
        XCTAssertEqual(refreshCallCount, 2)
        
        sut.surveyModels = [survey1, survey2]
        sut.simulateMoveNext()
        sut.simulateMovePrevious()
        sut.simulateMovePrevious()
        XCTAssertEqual(refreshCallCount, 3)

    }
    
    func test_userInitiatedTakeSurvey_messagesOnSurveyDetails() {
        let (sut, _) = makeSUT()
        
        var callCount = 0
        sut.onSurveyDetails = {
            callCount += 1
        }

        sut.simulateTakeSurveyButtonTap()
        
        XCTAssertEqual(callCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: SurveyViewController, loader: SurveyImageDataLoaderSpy) {
        let bundle = Bundle(for: SurveyViewController.self)
        let sb = UIStoryboard(name: "Main", bundle: bundle)
        let sut = sb.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        let loader = SurveyImageDataLoaderSpy()
        sut.imageLoader = loader
        sut.loadViewIfNeeded()
        checkForMemoryLeaks(sut)
        checkForMemoryLeaks(loader)
        return (sut, loader)
    }
    
    private class SurveyImageDataLoaderSpy: SurveyImageDataLoader {
        var loadedURLs = [URL]()
        var cancelledURLs = [URL]()
        
        private var completions = [(Result<Data, Error>) -> Void]()
        
        private struct Task: ImageDataTask {
            private let action: () -> Void
            
            init(action: @escaping () -> Void) {
                self.action = action
            }
            
            func cancel() {
                action()
            }
            
        }
        
        func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataTask {
            loadedURLs.append(url)
            completions.append(completion)
            
            return Task {[weak self] in self?.cancelImageLoad(from: url) }
        }
        
        func cancelImageLoad(from url: URL) {
            cancelledURLs.append(url)
        }
        
        func loadImageCompleteSuccessWith(data: Data, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
    
}

private extension SurveyViewController {
    func simulateMoveNext() {
        self.next()
    }
    
    func simulateMovePrevious() {
        self.previous()
    }
    
    func renderedImageData() -> Data? {
        backgroundImageView.image?.pngData()
    }
    
    func simulateTakeSurveyButtonTap() {
        takeSurveyButton.sendActions(for: .touchUpInside)
    }
}

