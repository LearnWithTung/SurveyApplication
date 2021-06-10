//
//  LoginUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest

class RemoteLoginService {
    private let url: URL
    private let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func login() {
        client.post(with: url)
    }
}

class HTTPClient {
    var requestedURL: URL?

    func post(with url: URL) {
        requestedURL = url
    }
}

class LoginUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_login_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.login()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteLoginService, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteLoginService(url: url, client: client)
        
        return (sut, client)
    }

}
