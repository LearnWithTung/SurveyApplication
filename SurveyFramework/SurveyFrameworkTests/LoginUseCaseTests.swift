//
//  LoginUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest

class RemoteLoginService {

}

class HTTPClient {
    var requestedURL: URL?

}

class LoginUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteLoginService()

        XCTAssertNil(client.requestedURL)
    }

}
