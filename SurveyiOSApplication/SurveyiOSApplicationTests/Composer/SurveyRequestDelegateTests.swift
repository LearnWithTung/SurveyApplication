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
            case let .success(surveys):
                completion(.success(surveys.toRepresentation()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}

extension Array where Element == Survey {
    
    func toRepresentation() -> [RepresentationSurvey] {
        self.map {
            RepresentationSurvey(title: $0.attributes.title, description: $0.attributes.description, imageURL: $0.attributes.imageURL.appendingPathComponent("l"))
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
    
    func test_load_deliversErrorOnLoadSurveysFailed() {
        let (sut, loader) = makeSUT()
        var capturedResult: Result<[RepresentationSurvey], Error>?
        sut.loadSurvey { capturedResult = $0}
        
        loader.completeWithError(anyNSError())
        
        XCTAssertThrowsError(try XCTUnwrap(capturedResult).get())
    }
    
    func test_load_deliversRepresentationSurveysOnLoadSucess() {
        let (sut, loader) = makeSUT()
        var capturedResult: Result<[RepresentationSurvey], Error>?
        sut.loadSurvey { capturedResult = $0}
        
        let survey1 = makeSurvey(id: UUID(), title: "title1", description: "desc1")
        let representationSurvey1 = RepresentationSurvey(title: survey1.attributes.title, description: survey1.attributes.description, imageURL: survey1.attributes.imageURL.appendingPathComponent("l"))

        let survey2 = makeSurvey(id: UUID(), title: "title1", description: "desc1")
        let representationSurvey2 = RepresentationSurvey(title: survey2.attributes.title, description: survey2.attributes.description, imageURL: survey2.attributes.imageURL.appendingPathComponent("l"))

        
        loader.completeSucessfully(with: [survey1, survey2])
        
        XCTAssertEqual(try XCTUnwrap(capturedResult).get(), [representationSurvey1, representationSurvey2])
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
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
    
    private func makeSurvey(id: UUID, title: String, description: String, url: URL = anyURL()) -> Survey {
        return Survey(id: id.uuidString,
                      attributes: .init(title: title, description: description, imageURL: url))
    }
    
}
