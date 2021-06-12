//
//  AuthenticatedHTTPClientDecoratorTestsAuthenticatedHTTPClientDecoratorTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 12/06/2021.
//

import XCTest
import SurveyFramework

class AuthenticatedHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let service: TokenLoader
    
    init(decoratee: HTTPClient, service: TokenLoader) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        var signedRequest = url
        service.load {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(token):
                signedRequest.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
                self.decoratee.request(from: signedRequest, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}

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
        let service = TokenLoaderStub(stubbedError: NSError(domain: "test", code: 0, userInfo: nil))
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        let unsignedRequest = URLRequest(url: URL(string: "https://a-url.com")!)
        
        var capturedResult: HTTPClient.HTTPClientResult?
        sut.request(from: unsignedRequest) {
            capturedResult = $0
        }
        
        XCTAssertEqual(client.requestedURLs, [])
        XCTAssertThrowsError(try capturedResult?.get())
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
    
    private func httpURLResponse(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        private var completions = [(HTTPClientResult) -> Void]()
        
        func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with values: (data: Data, response: HTTPURLResponse), at index: Int = 0) {
            completions[index](.success(values))
        }
    }
    
}

private extension URLRequest {
    
    func signRequest(with token: Token) -> URLRequest {
        var signedRequest = self
        signedRequest.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return signedRequest
    }
    
}
