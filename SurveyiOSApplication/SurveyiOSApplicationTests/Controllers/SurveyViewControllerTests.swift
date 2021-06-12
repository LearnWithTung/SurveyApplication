//
//  SurveyViewControllerTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 12/06/2021.
//

import XCTest
@testable import SurveyiOSApplication

class SurveyViewControllerTests: XCTestCase {
    
    func test_emptyData_rendersEmptyViews() {
        let sut = makeSUT()
        
        sut.surveyModels = []
        
        XCTAssertEqual(sut.backgroundImageView.image, nil)
        XCTAssertEqual(sut.descriptionLabel.text, nil)
        XCTAssertEqual(sut.titleLabel.text, nil)
        XCTAssertEqual(sut.pageControl.numberOfPages, 0)
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
