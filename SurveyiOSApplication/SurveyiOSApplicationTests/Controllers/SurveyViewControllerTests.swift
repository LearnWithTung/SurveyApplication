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
        let sut = makeSUT()
        
        sut.surveyModels = []
        
        XCTAssertEqual(sut.backgroundImageView.image, nil)
        XCTAssertEqual(sut.descriptionLabel.text, nil)
        XCTAssertEqual(sut.titleLabel.text, nil)
        XCTAssertEqual(sut.pageControl.numberOfPages, 0)
    }
    
    func test_renders_firstViewOnNonEmptyDataSource() {
        let sut = makeSUT()
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
        let sut = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        
        sut.simulateMoveNext()
        
        XCTAssertEqual(sut.titleLabel.text, survey2.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey2.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 2)
    }
    
    func test_userInitiatedNextView_doesNotRenderNextModelOnAtEdge() {
        let sut = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        
        sut.surveyModels = [survey1]
        
        sut.simulateMoveNext()
        
        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
    }
    
    func test_userInitiatedPreviousView_rendersPreviousModel() {
        let sut = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
        
        sut.surveyModels = [survey1, survey2]
        
        sut.simulateMoveNext()
        sut.simulateMovePrevious()

        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 2)
    }
    
    func test_userInitiatedPreviousView_doesNotRenderPreviousModelOnAtEdge() {
        let sut = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        
        sut.surveyModels = [survey1]
        
        sut.simulateMovePrevious()

        XCTAssertEqual(sut.titleLabel.text, survey1.title)
        XCTAssertEqual(sut.descriptionLabel.text, survey1.description)
        XCTAssertEqual(sut.pageControl.numberOfPages, 1)
    }
    
    func test_updateDataSource_resetCurrentIndex() {
        let sut = makeSUT()
        let survey1 = RepresentationSurvey(title: "survey1", description: "description1", imageURL: URL(string: "https://a-url-1.com")!)
        let survey2 = RepresentationSurvey(title: "survey2", description: "description2", imageURL: URL(string: "https://a-url-2.com")!)
                
        sut.surveyModels = [survey1, survey2]
        XCTAssertEqual(sut.currentIndex, 0)
        
        sut.simulateMoveNext()
        XCTAssertEqual(sut.currentIndex, 1)

        sut.surveyModels = [survey1]
        XCTAssertEqual(sut.currentIndex, 0)
    }
    
    
    // MARK: - Helpers
    private func makeSUT() -> SurveyViewController {
        let bundle = Bundle(for: SurveyViewController.self)
        let sb = UIStoryboard(name: "Main", bundle: bundle)
        let sut = sb.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        sut.loadViewIfNeeded()
        checkForMemoryLeaks(sut)
        return sut
    }
    
}

private extension SurveyViewController {
    func simulateMoveNext() {
        self.next()
    }
    
    func simulateMovePrevious() {
        self.previous()
    }
}
