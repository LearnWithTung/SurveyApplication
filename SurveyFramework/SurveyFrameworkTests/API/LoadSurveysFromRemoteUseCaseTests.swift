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
    
}

class LoadSurveysFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteSurveysLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSurveysLoader(url: url, client: client)
        checkForMemoryLeaks(client, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(urlRequest: URLRequest,
                                 completion: (HTTPClient.HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map {$0.urlRequest}
        }
        
        func post(with request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
            messages.append((request, completion))
        }
        
        func completeWithError(_ error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func completeWithStatusCode(_ code: Int, data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: requestedURLs[index].url!, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, httpResponse)))
        }
        
    }
}
