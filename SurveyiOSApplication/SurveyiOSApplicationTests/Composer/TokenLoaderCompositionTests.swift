//
//  TokenLoaderCompositionTests.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import XCTest
import SurveyFramework
import SurveyiOSApplication

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
    
    func test_getToken_deliversTokenFromRemote() {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate)
        store.save(token: token) {_ in}
        
        var capturedResult: TokenLoader.TokenSaverResult?
        sut.load { capturedResult = $0 }
        
        let newToken = anyNonExpirationToken(currentDate: currentDate)
        loader.completeSuccessful(with: newToken)
        
        XCTAssertEqual(try? XCTUnwrap(capturedResult).get(), newToken)
    }
    
    func test_getToken_failsOnFailedLoadTokenFromRemote() {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate)
        store.save(token: token) {_ in}
        
        var capturedResult: TokenLoader.TokenSaverResult?
        sut.load { capturedResult = $0 }
        
        loader.completeWithError()
        
        XCTAssertThrowsError(try XCTUnwrap(capturedResult).get())
    }
    
    func test_getToken_requetsTokenFromRemoteWithRefreshToken() {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate, refreshToken: "a refresh token")
        store.save(token: token) {_ in}
        
        sut.load { _ in }
        
        loader.completeWithError()
        
        XCTAssertEqual(loader.refreshToken(), token.refreshToken)
    }
    
    func test_sendRequest_multipleTimes_reusesRunningTokenRequest() {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate)
        store.save(token: token) {_ in}

        XCTAssertEqual(loader.requestCallCount, 0)
        
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(loader.requestCallCount, 1)
        
        loader.completeSuccessful(with: anyNonExpirationToken(currentDate: currentDate))
        
        sut.load { _ in }
        XCTAssertEqual(loader.requestCallCount, 2)
    }
    
    func test_sendRequest_multipleTimesInDifferentThreads_appendingRequestSerially() throws {
        let currentDate = Date()
        let expiredDate = currentDate.adding(seconds: -1)
        let (loader, store, sut) = makeSUT {currentDate}
        let token = makeTokenWith(expiredDate: expiredDate)
        store.save(token: token) {_ in}

        let exp = expectation(description: "Wait for completion")
        exp.expectedFulfillmentCount = 2
        
        DispatchQueue.global().async {
            sut.load { _ in }
            exp.fulfill()
        }
        
        DispatchQueue.global().async {
            sut.load { _ in }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(loader.requestCallCount, 1)
        loader.completeSuccessful(with: anyNonExpirationToken(currentDate: currentDate))

        sut.load { _ in }
        XCTAssertEqual(loader.requestCallCount, 2)
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
    
    private class RemoteTokenLoaderSpy: RemoteTokenLoader {
        var requestCallCount: Int = 0
        private var messages = [(refreshToken: String, completion: (RemoteTokenLoader.RemoteTokenResult) -> Void)]()
        
        init() {
            super.init(url: URL(string: "https://any-url.com")!,
                       client: HTTPClientSpy(),
                       credentials: .init(client_id: "any", client_secret: "any"),
                       currentDate: Date.init)
        }
        
        override func load(withRefreshToken token: String, completion: @escaping (RemoteTokenLoader.RemoteTokenResult) -> Void) {
            requestCallCount += 1
            messages.append((token, completion))
        }
        
        func completeSuccessful(with token: Token, at index: Int = 0) {
            messages[index].completion(.success(token))
        }
        
        func completeWithError(at index: Int = 0) {
            messages[index].completion(.failure(.invalidData))
        }
        
        func refreshToken(at index: Int = 0) -> String {
            messages[index].refreshToken
        }
    }
    
    
    private func makeTokenWith(expiredDate: Date, refreshToken: String = "any") -> Token {
        Token(accessToken: "any", tokenType: "any", expiredDate: expiredDate, refreshToken: refreshToken)
    }
    
    private func anyNonExpirationToken(currentDate: Date) -> Token {
        let validDate = currentDate.adding(seconds: 1)
        return makeTokenWith(expiredDate: validDate)
    }


}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
