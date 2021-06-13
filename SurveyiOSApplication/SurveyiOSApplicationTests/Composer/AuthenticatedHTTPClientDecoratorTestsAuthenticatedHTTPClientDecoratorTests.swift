//
//  AuthenticatedHTTPClientDecoratorTestsAuthenticatedHTTPClientDecoratorTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 12/06/2021.
//

import XCTest
import SurveyFramework
import SurveyiOSApplication

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_sendRequest_withSuccessfulTokenRequest_signsRequestWithToken() {
        let client = HTTPClientSpy()
        let token = Token(accessToken: "access token", tokenType: "token type", expiredDate: Date(), refreshToken: "refresh token")
        let service = TokenLoaderStub(stubbedToken: token)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        let unsignedRequest = URLRequest(url: URL(string: "https://a-url.com")!)
        let signedRequest = unsignedRequest.signRequest(with: token)
        
        sut.request(from: unsignedRequest) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [signedRequest])
    }
    
    func test_sendRequest_withSuccessfulTokenRequest_completesWithDecorateeResult() throws {
        let values = (Data("any data".utf8), httpURLResponse(200))
        let client = HTTPClientSpy()
        let token = Token(accessToken: "access token", tokenType: "token type", expiredDate: Date(), refreshToken: "refresh token")
        let service = TokenLoaderStub(stubbedToken: token)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        let unsignedRequest = URLRequest(url: URL(string: "https://a-url.com")!)
        
        var capturedResult: HTTPClient.HTTPClientResult?
        sut.request(from: unsignedRequest) {
            capturedResult = $0
        }
        client.complete(with: values)
        
        let receivedValues = try XCTUnwrap(capturedResult).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
    }
    
    func test_sendRequest_withFailedTokenRequest_fails() {
        let client = HTTPClientSpy()
        let service = TokenLoaderStub(stubbedError: anyNSError())
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        var capturedResult: HTTPClient.HTTPClientResult?
        sut.request(from: anyRequest()) {
            capturedResult = $0
        }
        
        XCTAssertEqual(client.requestedURLs, [])
        XCTAssertThrowsError(try capturedResult?.get())
    }
    
    func test_sendRequest_multipleTimes_reusesRunningTokenRequest() {
        let client = HTTPClientSpy()
        let service = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        XCTAssertEqual(service.requestTokenCallCount, 0)
        
        sut.request(from: anyRequest()) {_ in}
        sut.request(from: anyRequest()) {_ in}
        
        XCTAssertEqual(service.requestTokenCallCount, 1)
        
        service.complete(with: anyNSError())
        
        sut.request(from: anyRequest()) {_ in}
        
        XCTAssertEqual(service.requestTokenCallCount, 2)
    }
    
    func test_sendRequest_multipleTimes_completesWithRespectiveClientResult() throws {
        let client = HTTPClientSpy()
        let service = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        var capturedResult1: HTTPClient.HTTPClientResult?
        sut.request(from: anyRequest()) {capturedResult1 = $0}
        
        var capturedResult2: HTTPClient.HTTPClientResult?
        sut.request(from: anyRequest()) {capturedResult2 = $0}
                
        service.completeSuccessfully(with: anyToken())
        
        let values = (Data("any data".utf8), httpURLResponse(200))
        client.complete(with: values, at: 0)
        let receivedValues1 = try XCTUnwrap(capturedResult1).get()
        XCTAssertEqual(receivedValues1.0, values.0)
        XCTAssertEqual(receivedValues1.1, values.1)

        client.complete(with: anyNSError(), at: 1)
        XCTAssertThrowsError(try capturedResult2?.get())
    }
    
    func test_sendRequest_multipleTimesInDifferentThreads_appendingRequestSerially() throws {
        let client = HTTPClientSpy()
        let service = TokenLoaderSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 2
        
        DispatchQueue.global().async {
            sut.request(from: self.anyRequest()) {_ in}
            exp.fulfill()
        }
        
        DispatchQueue.global().async {
            sut.request(from: self.anyRequest()) {_ in}
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(service.requestTokenCallCount, 1)
        service.completeSuccessfully(with: anyToken())
        
        sut.request(from: anyRequest()) {_ in}
        XCTAssertEqual(service.requestTokenCallCount, 2)
    }
    
    // MARK: - Helpers
    private class TokenLoaderStub: TokenLoader {
        var stubbedToken: Token?
        var stubbedError: Error?
        
        init(stubbedToken: Token) {
            self.stubbedToken = stubbedToken
        }
        
        init(stubbedError: Error) {
            self.stubbedError = stubbedError
        }
        
        func load(completion: @escaping (Result<Token, Error>) -> Void) {
            if let token = stubbedToken {
                completion(.success(token))
            }
            if let error = stubbedError {
                completion(.failure(error))
            }
        }
    }
    
    private class TokenLoaderSpy: TokenLoader {
        var requestTokenCallCount: Int = 0
        private var completions = [(TokenSaverResult) -> Void]()
        
        func load(completion: @escaping (TokenSaverResult) -> Void) {
            requestTokenCallCount += 1
            self.completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeSuccessfully(with token: Token, at index: Int = 0) {
            completions[index](.success(token))
        }
    }
    
    private func anyToken() -> Token {
        Token(accessToken: "any", tokenType: "any", expiredDate: Date(), refreshToken: "any")
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0, userInfo: nil)
    }
    
    private func anyRequest() -> URLRequest {
        return URLRequest(url: anyURL())
    }
    
    private func httpURLResponse(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}

private extension URLRequest {
    
    func signRequest(with token: Token) -> URLRequest {
        var signedRequest = self
        signedRequest.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return signedRequest
    }
    
}
