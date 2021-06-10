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

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_login_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.login(with: anyLoginInfo())
        
        XCTAssertEqual(client.requestedURLs.map {$0.url}, [url])
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
        
        let urlRequest = client.requestedURLs[0]
        let requestedBody = try! JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: String]
        
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(requestedBody, body)
    }
    
    func test_login_deliversErrorOnClientError() {
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteLoginService.Error?
        sut.login(with: anyLoginInfo()) { error in
            capturedError = error
        }
        
        client.completeWithError(clientError)
        
        XCTAssertEqual(capturedError, .connectivity)
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
        var requestedURLs = [URLRequest]()
        var completions = [(HTTPClient.HTTPClientResult) -> Void]()
        
        func post(with request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
            requestedURLs.append(request)
            completions.append(completion)
        }
        
        func completeWithError(_ error: Error, at index: Int = 0){
            completions[index](error)
        }
        
    }

}
