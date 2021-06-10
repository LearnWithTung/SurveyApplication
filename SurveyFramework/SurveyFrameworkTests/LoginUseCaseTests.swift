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
}

class HTTPClient {
    var requestedURL: URL?

}

class LoginUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClient()
        _ = RemoteLoginService(url: url, client: client)

        XCTAssertNil(client.requestedURL)
    }

}
