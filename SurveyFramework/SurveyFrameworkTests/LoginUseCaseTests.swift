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
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClient()
        _ = RemoteLoginService(url: url, client: client)

        XCTAssertNil(client.requestedURL)
    }
    
    func test_login_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClient()
        let sut = RemoteLoginService(url: url, client: client)
        
        sut.login()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
