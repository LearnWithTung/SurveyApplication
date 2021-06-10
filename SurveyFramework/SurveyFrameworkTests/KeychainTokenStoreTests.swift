//
//  KeychainTokenStoreTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest
import SurveyFramework

class KeychainTokenStoreTests: XCTestCase {

    func test_load_returnsErrorWhenNothingSaved() {
        let sut = makeSUT()

        let capturedResult = loadTokenFrom(sut)

        XCTAssertThrowsError(try capturedResult?.get())
    }
    
    func test_load_returnsSavedToken() {
        let sut = makeSUT()
        let token = makeToken()
        
        saveTokenWith(sut, token: token)
                
        let capturedResult = loadTokenFrom(sut)

        XCTAssertEqual(try? capturedResult?.get(), token)
    }
    
    func test_load_returnsLastSavedToken() {
        let sut1 = makeSUT()
        let sut2 = makeSUT()
        let token1 = makeToken(accessToken: "access token 1")
        let token2 = makeToken(accessToken: "access token 2")
        
        saveTokenWith(sut1, token: token1)
        saveTokenWith(sut1, token: token2)
        
        let capturedResult = loadTokenFrom(sut2)
        
        XCTAssertEqual(try? capturedResult?.get(), token2)
    }
    
    // MARK: - Helpers
    func makeSUT() -> KeychainTokenStore {
        let sut = KeychainTokenStore()
        KeychainTokenStore().clear()
        checkForMemoryLeaks(sut)
        return sut
    }
    
    private func saveTokenWith(_ sut: KeychainTokenStore, token: Token) {
        let exp = expectation(description: "Wait for saving completion")
        
        sut.save(token: token) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    private func loadTokenFrom(_ sut: KeychainTokenStore) -> Result<Token, Error>? {
        let exp = expectation(description: "Wait for saving completion")
        
        var capturedResult: Result<Token, Error>?
        sut.load {
            capturedResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        return capturedResult
    }
    
    private func makeToken(accessToken: String = "any", tokenType: String = "any", expiredDate: Date = Date(), refreshToken: String = "any") -> Token {
        Token(accessToken: accessToken,
              tokenType: tokenType,
              expiredDate: expiredDate,
              refreshToken: refreshToken)
    }

}
