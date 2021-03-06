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
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.load(with: anyLoginInfo()) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.load(with: anyLoginInfo()) {_ in}
        sut.load(with: anyLoginInfo()) {_ in}

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_signsRequestWithBodyParams() {
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
        
        sut.load(with: info) {_ in}
        
        let urlRequest = client.requestedURLRequests[0]
        let requestedBody = try! JSONSerialization.jsonObject(with: urlRequest.httpBody!) as! [String: String]

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(requestedBody, body)
    }
    
    func test_load_deliversErrorOnClientError() {
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            client.completeWithError(clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                let jsonData = makeTokenJSONData(from: makeTokenJSONWith().json)
                client.completeWithStatusCode(code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("invalid data".utf8)
            client.completeWithStatusCode(200, data: invalidJSON)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let emptyData = Data()
            client.completeWithStatusCode(200, data: emptyData)
        }
    }
    
    func test_load_succeedsOn200HTTPResponseWithTokenJSON() {
        let currentDate = Date()
        let (sut, client) = makeSUT(currentDate: { currentDate })
        
        let token = makeTokenJSONWith(accessToken: "access token",
                                      tokenType: "token type",
                                      currentDate: currentDate,
                                      refreshToken: "refresh token",
                                      expiresIn: 60)

        expect(sut, toCompleteWithToken: token.model) {
            let jsonData = makeTokenJSONData(from: token.json)
            client.completeWithStatusCode(200, data: jsonData)
        }
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let credentials = Credentials(client_id: "any", client_secret: "any")
        var sut: RemoteLoginService? = RemoteLoginService(url: anyURL(), client: client, credentials: credentials, currentDate: {Date()})
        
        var capturedResult: RemoteLoginService.RemoteLoginResult?
        sut?.load(with: anyLoginInfo()) { capturedResult = $0 }

        sut = nil
        
        client.completeWithStatusCode(199)
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, credentials: Credentials = Credentials(client_id: "any", client_secret: "any"), currentDate: @escaping () -> Date = { Date() }) -> (sut: RemoteLoginService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoginService(url: url, client: client, credentials: credentials, currentDate: currentDate)
        checkForMemoryLeaks(client)
        checkForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func makeTokenJSONWith(accessToken: String = "any", tokenType: String = "any", currentDate: Date = Date(), refreshToken: String = "any", expiresIn: Int = 0) -> (model: Token, json: [String: Any]) {
        let calendar = Calendar(identifier: .gregorian)
        let expiredDate = calendar.date(byAdding: .second, value: expiresIn, to: currentDate)!
        
        let token = makeToken(accessToken: accessToken, tokenType: tokenType, expiredDate: expiredDate, refreshToken: refreshToken)

        let tokenJSON = [
            "access_token": token.accessToken,
            "token_type": token.tokenType,
            "expires_in": expiresIn,
            "refresh_token": token.refreshToken
        ] as [String : Any]

        return (token, tokenJSON)
    }
    
    private func expect(_ sut: RemoteLoginService, toCompleteWithToken token: Token, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        var capturedToken: Token?
        sut.load(with: anyLoginInfo()) { result in
            switch result {
            case let .success(receivedToken):
                capturedToken = receivedToken
            default:
                break
            }
            exp.fulfill()
        }
            
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedToken, token, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteLoginService, toCompleteWithError error: RemoteLoginService.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: RemoteLoginService.Error?
        sut.load(with: anyLoginInfo()) { result in
            switch result {
            case let .failure(error as RemoteLoginService.Error):
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
    
    private func anyLoginInfo() -> LoginInfo {
        .init(email: "any email", password: "any password")
    }

}
