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
    private let currentDate: () -> Date
    init(store: KeychainTokenStore, remoteTokenLoader: RemoteTokenLoader, currentDate: @escaping () -> Date) {
        self.store = store
        self.remoteTokenLoader = remoteTokenLoader
        self.currentDate = currentDate
    }
    
    func load(completion: @escaping (TokenSaverResult) -> Void) {
        store.load {[weak self] tokenResult in
            guard let self = self else {return}
            switch tokenResult {
            case let .success(token) where token.expiredDate > self.currentDate():
                completion(.success(token))
            case .success:
                self.remoteTokenLoader.load(withRefreshToken: "") {_ in}
            case let .failure(error):
                completion(.failure(error))
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
        let currentDate = Date()
        let nonExpiredDate = currentDate.adding(seconds: 1)
        let (_, store, sut) = makeSUT(currentDate: { currentDate })
        let token = makeTokenWith(expiredDate: nonExpiredDate)
        store.save(token: token) {_ in}
        
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
    
    func test_getToken_withEmptyStore_fails() {
        let (_, _, sut) = makeSUT()

        let exp = expectation(description: "wait for completion")
        
        var capturedResult: TokenLoader.TokenSaverResult?
        sut.load {
            capturedResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertThrowsError(try XCTUnwrap(capturedResult).get())
    }
    
    func test_getToken_requestsTokenFromRemoteOnExpiredTokenFromStore() {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate)
        store.save(token: token) {_ in}
                
        XCTAssertEqual(loader.requestCallCount, 0)
        
        sut.load { _ in }
                    
        XCTAssertEqual(loader.requestCallCount, 1)
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (loader: RemoteTokenLoaderSpy, store: KeychainTokenStore, sut: TokenLoaderComposition) {
        let stub = RemoteTokenLoaderSpy()
        let store = KeychainTokenStore()
        let sut = TokenLoaderComposition(store: store, remoteTokenLoader: stub, currentDate: Date.init)
        
        checkForMemoryLeaks(stub, file: file, line: line)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (stub, store, sut)
    }
    
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
    
    private class RemoteTokenLoaderSpy: RemoteTokenLoader {
        var requestCallCount: Int = 0
        
        init() {
            super.init(url: URL(string: "https://any-url.com")!,
                       client: HTTPClientSpy(),
                       credentials: .init(client_id: "any", client_secret: "any"),
                       currentDate: Date.init)
        }
        
        override func load(withRefreshToken token: String, completion: @escaping (RemoteTokenLoader.RemoteTokenResult) -> Void) {
            requestCallCount += 1
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
    
    private func makeTokenWith(expiredDate: Date) -> Token {
        Token(accessToken: "any", tokenType: "any", expiredDate: expiredDate, refreshToken: "any")
    }


}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
