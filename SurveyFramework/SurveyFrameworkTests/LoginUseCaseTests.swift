//
//  LoginUseCaseTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest
import SurveyFramework

class LoginUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_login_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.login(with: anyLoginInfo())
        
        XCTAssertEqual(client.requestedURL?.url, url)
    }
    
    func test_loginTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.login(with: anyLoginInfo())
        sut.login(with: anyLoginInfo())

        XCTAssertEqual(client.requestedURLs.map{$0.url}, [url, url])
    }
    
    func test_login_signsRequestWithBodyParams() {
        let credentials = Credentials(client_id: "a clientId", client_secret: "a secret")
        let info = LoginInfo(email: "an email", password: "a password")
        let body = [
            "grant_type": "password",
            "email": info.email,
            "password": info.password,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret
        ]
        let (sut, client) = makeSUT(credentials: credentials)
        
        sut.login(with: info)
        
        let requestedBody = try! JSONSerialization.jsonObject(with: client.requestedURL!.httpBody!) as! [String: String] 
        
        XCTAssertEqual(client.requestedURL?.httpMethod, "POST")
        XCTAssertEqual(requestedBody, body)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, credentials: Credentials = Credentials(client_id: "any", client_secret: "any")) -> (sut: RemoteLoginService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoginService(url: url, client: client, credentials: credentials)
        
        return (sut, client)
    }
    
    private func anyLoginInfo() -> LoginInfo {
        .init(email: "any email", password: "any password")
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URLRequest?
        var requestedURLs = [URLRequest]()

        func post(with request: URLRequest) {
            requestedURL = request
            requestedURLs.append(request)
        }
    }

}
