//
//  KeychainStore.swift
//  SurveyFramework
//
//  Created by Tung Vu on 16/06/2021.
//

import Foundation

public protocol KeychainSaver {
    associatedtype KeychainModel
    func save(model: KeychainModel, completion: @escaping (Result<Void, Swift.Error>) -> Void)
}

public final class KeychainStore<Model>: KeychainSaver where Model: Codable {
    
    private let key: String
    
    public init(key: String) {
        self.key = key
    }
    
    enum Error: Swift.Error {
        case dataNotFound
        case saveFailed
    }
    
    public func save(model: Model, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(model)
            
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
