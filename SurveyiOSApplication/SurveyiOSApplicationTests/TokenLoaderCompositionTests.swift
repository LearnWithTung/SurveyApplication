//
//  TokenLoaderCompositionTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyFramework

class TokenLoaderComposition: TokenLoader {
    private let store: KeychainTokenStore
    private let remoteTokenLoader: RemoteTokenLoader
    
    init(store: KeychainTokenStore, remoteTokenLoader: RemoteTokenLoader) {
        self.store = store
        self.remoteTokenLoader = remoteTokenLoader
    }
    
    func load(completion: @escaping (TokenSaverResult) -> Void) {
        store.load { tokenResult in
            switch tokenResult {
            case let .success(token):
                completion(.success(token))
            default:
                break
            }
        }
    }
}

class TokenLoaderCompositionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        KeychainTokenStore().clear()
    }
    
    override func tearDown() {
        super.tearDown()
        
        KeychainTokenStore().clear()
    }
    
    func test_getToken_withValidTokenFromStore_deliversToken() throws {
        let stub = RemoteTokenLoaderStub()
        let store = KeychainTokenStore()
        let token = anyToken()
        store.save(token: token) {_ in}
        let sut = TokenLoaderComposition(store: store, remoteTokenLoader: stub)
        let exp = expectation(description: "wait for completion")
        
        var capturedResult: TokenLoader.TokenSaverResult?
        sut.load {
            capturedResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        let receivedToken = try XCTUnwrap(capturedResult).get()
        
        XCTAssertEqual(receivedToken, token)
    }
    
    // MARK: - Helpers
    private class TokenLoaderStub: TokenLoader {
        var stubbedToken: Token?
        var stubbedError: Error?
        
        init() {}
        
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
    
    private class RemoteTokenLoaderStub: RemoteTokenLoader {
        init() {
            super.init(url: URL(string: "https://any-url.com")!,
                       client: HTTPClientSpy(),
                       credentials: .init(client_id: "any", client_secret: "any"),
                       currentDate: Date.init)
        }
        
        override func load(withRefreshToken token: String, completion: @escaping (RemoteTokenLoader.RemoteTokenResult) -> Void) {
            
        }
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
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
    
    private func anyToken() -> Token {
        Token(accessToken: "any", tokenType: "any", expiredDate: Date(), refreshToken: "any")
    }


}


