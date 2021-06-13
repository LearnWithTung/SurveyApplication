//
//  SurveyRequestDelegateTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyiOSApplication
import SurveyFramework

class SurveyRequestDelegate: HomeViewControllerDelegate {
    private let loader: SurveyLoader
    
    init(loader: SurveyLoader) {
        self.loader = loader
    }
    
    func loadSurvey(completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
        loader.load(query: .init(pageNumber: 1, pageSize: 3)) { result in
            switch result {
            case .success:
                completion(.success([]))
            default:
                break
            }
        }
    }
    
}

class SurveyRequestsDelegateTests: XCTestCase {
    
    func test_load_deliversEmptyOnSuccessWithEmptyList() {
        let (sut, loader) = makeSUT()
        
        var capturedResult: Result<[RepresentationSurvey], Error>?
        sut.loadSurvey { capturedResult = $0}
        
        loader.completeSucessfully(with: [])
        
        XCTAssertEqual(try XCTUnwrap(capturedResult).get(), [])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: SurveyRequestDelegate, loader: SurveyLoaderSpy) {
        let loader = SurveyLoaderSpy()
        let sut = SurveyRequestDelegate(loader: loader)
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class SurveyLoaderSpy: SurveyLoader {
        private var completions = [(LoadSurveyResult) -> Void]()
        
        func load(query: SurveyQuery, completion: @escaping (LoadSurveyResult) -> Void) {
            completions.append(completion)
        }
        
        func completeSucessfully(with surveys: [Survey], at index: Int = 0) {
            completions[index](.success(surveys))
        }
    }
    
}
