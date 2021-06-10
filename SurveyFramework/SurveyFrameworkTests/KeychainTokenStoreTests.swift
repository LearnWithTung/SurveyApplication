//
//  KeychainTokenStoreTests.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import XCTest
import SurveyFramework

class KeychainTokenStore {
    struct LocalToken: Codable {
        let accessToken: String
        let tokenType: String
        let expiredDate: Date
        let refreshToken: String
        
        init(tokens: Token) {
            self.accessToken = tokens.accessToken
            self.tokenType = tokens.tokenType
            self.expiredDate = tokens.expiredDate
            self.refreshToken = tokens.refreshToken
        }
        
        var model: Token {
            return Token(accessToken: accessToken, tokenType: tokenType, expiredDate: expiredDate, refreshToken: refreshToken)
        }
    }

    enum Error: Swift.Error {
        case dataNotFound
        case saveFailed
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
    
    func save(token: Token, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(LocalToken(tokens: token))
            
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query)
            
            guard SecItemAdd(query, nil) == noErr else {
                throw Error.saveFailed
            }
            
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func load(completion: @escaping (Result<Token, Swift.Error>) -> Void) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimit
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == noErr, let data = result as? Data else {
            return completion(.failure(Error.dataNotFound))
        }
        
        do {
            let token = try JSONDecoder().decode(LocalToken.self, from: data)
            completion(.success(token.model))
        } catch {
            completion(.failure(error))
        }
    }
}

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
