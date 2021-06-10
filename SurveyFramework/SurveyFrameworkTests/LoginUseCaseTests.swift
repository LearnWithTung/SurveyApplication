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

struct Credentials {
    let client_id: String
    let client_secret: String
}

class RemoteLoginService {
    private let url: URL
    private let client: HTTPClient
    private let credentials: Credentials
    
    init(url: URL, client: HTTPClient, credentials: Credentials) {
        self.client = client
        self.url = url
        self.credentials = credentials
    }
    
    func login(with info: LoginInfo) {
        let body = [
            "grant_type": "password",
            "email": info.email,
            "password": info.password,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
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
    
    func test_login_signsRequestWithBodyParams() {
        let url = URL(string: "https://a-url.com")!
        let credentials = Credentials(client_id: "a clientId", client_secret: "a secret")
        let info = LoginInfo(email: "an email", password: "a password")
        let body = [
            "grant_type": "password",
            "email": info.email,
            "password": info.password,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret
        ]
        let (sut, client) = makeSUT(url: url, credentials: credentials)
        
        sut.login(with: info)
        
        let requestedBody = try! JSONSerialization.jsonObject(with: client.requestedURL!.httpBody!) as! [String: String] 
        
        XCTAssertEqual(client.requestedURL?.httpMethod, "POST")
        XCTAssertEqual(requestedBody, body)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, credentials: Credentials = Credentials(client_id: "any", client_secret: "any")) -> (sut: RemoteLoginService, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteLoginService(url: url, client: client, credentials: credentials)
        
        return (sut, client)
    }

}
