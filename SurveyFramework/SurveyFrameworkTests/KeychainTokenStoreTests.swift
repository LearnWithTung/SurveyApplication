//
//  KeychainTokenStoreTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest

class KeychainTokenStore {

    enum Error: Swift.Error {
        case dataNotFound
    }

    func load(completion: @escaping (Result<Any, Swift.Error>) -> Void) {
        completion(.failure(Error.dataNotFound))
    }
    
    private var key: String {
        return "KeychainTokenStore.AccessToken"
    }

    func clear() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}

class KeychainTokenStoreTests: XCTestCase {

    func test_load_returnsErrorWhenNothingSaved() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        var capturedResult: Result<Any, Error>?
        sut.load {
            capturedResult = $0.mapError { $0 as NSError }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)

        XCTAssertThrowsError(try capturedResult?.get())
    }
    
    // MARK: - Helpers
    func makeSUT() -> KeychainTokenStore {
        let sut = KeychainTokenStore()
        KeychainTokenStore().clear()
        checkForMemoryLeaks(sut)
        return sut
    }

}
