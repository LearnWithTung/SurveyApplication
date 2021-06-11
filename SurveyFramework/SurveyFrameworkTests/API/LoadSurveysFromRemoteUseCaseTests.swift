//
//  LoadSurveysFromRemoteUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest
import SurveyFramework

struct SurveyQuery {
    let pageNumber: Int
    let pageSize: Int
}

class RemoteSurveysLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    func load(query: SurveyQuery, completion: @escaping (Result<[Survey], Error>) -> Void) {
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(query.pageNumber)"),
            URLQueryItem(name: "page[size]", value: "\(query.pageSize)")
        ]
        
        let enrichURL = urlComponent.url!
        let request = URLRequest(url: enrichURL)

        client.get(from: request) { _ in
            completion(.failure(.connectivity))
        }
    }
    
}

class LoadSurveysFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedGETURLRequests.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        let query = SurveyQuery(pageNumber: 1, pageSize: 2)
        let expectedURL = makeURL(from: url, query: query)
        
        sut.load(query: query) {_ in}
        
        XCTAssertEqual(client.requestedGETURLRequests.map {$0.url}, [expectedURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        let query = SurveyQuery(pageNumber: 1, pageSize: 2)
        let expectedURL = makeURL(from: url, query: query)
        
        sut.load(query: query) {_ in}
        sut.load(query: query) {_ in}

        XCTAssertEqual(client.requestedGETURLRequests.map {$0.url}, [expectedURL, expectedURL])
    }
    
    func test_login_deliversErrorOnClientError() {
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            client.completeWithError(clientError)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteSurveysLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSurveysLoader(url: url, client: client)
        checkForMemoryLeaks(client, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteSurveysLoader, toCompleteWithError error: RemoteSurveysLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: RemoteSurveysLoader.Error?
        sut.load(query: anyQuery()) { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                break
            }
            exp.fulfill()
        }
            
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedError, error, file: file, line: line)
    }
    
    private func anyQuery() -> SurveyQuery {
        return .init(pageNumber: 1, pageSize: 1)
    }
    
    private func makeURL(from url: URL = URL(string: "https://any-url.com")!, query: SurveyQuery = SurveyQuery(pageNumber: 0, pageSize: 0)) -> URL {
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(query.pageNumber)"),
            URLQueryItem(name: "page[size]", value: "\(query.pageSize)")
        ]
        
        return urlComponent.url!
    }

}
