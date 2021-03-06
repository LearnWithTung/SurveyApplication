//
//  KeychainTokenStore.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public final class KeychainTokenStore {
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
    
    public init() {}

    enum Error: Swift.Error {
        case dataNotFound
        case saveFailed
    }
    
    private var key: String {
        return "KeychainTokenStore.AccessToken"
    }
}

extension KeychainTokenStore: TokenCleaner {
    public func clear() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}


extension KeychainTokenStore: TokenSaver {
    public func save(token: Token, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
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
}
    
extension KeychainTokenStore: TokenLoader {
    public func load(completion: @escaping (TokenLoader.TokenSaverResult) -> Void) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
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
