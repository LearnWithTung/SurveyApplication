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
                self.decoratee.request(from: signedRequest) {_ in}
            default:
                break
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
    
    // MARK: - Helpers
    private class TokenLoaderStub: TokenLoader {
        var stubbedToken: Token?
        
        init(stubbedToken: Token) {
            self.stubbedToken = stubbedToken
        }
        
        func load(completion: @escaping (Result<Token, Error>) -> Void) {
            if let token = stubbedToken {
                completion(.success(token))
            }
        }
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        
        func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
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
