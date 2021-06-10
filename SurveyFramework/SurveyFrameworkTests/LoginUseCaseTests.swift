//
//  LoginUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest

struct LoginInfo {
    let email: String
    let password: String
}

class RemoteLoginService {
    private let url: URL
    private let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func login(with info: LoginInfo) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        client.post(with: request)
    }
}

class HTTPClient {
    var requestedURL: URLRequest?

    func post(with request: URLRequest) {
        requestedURL = request
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

        sut.login(with: .init(email: "any email", password: "any password"))
        
        XCTAssertEqual(client.requestedURL?.url, url)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteLoginService, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteLoginService(url: url, client: client)
        
        return (sut, client)
    }

}
