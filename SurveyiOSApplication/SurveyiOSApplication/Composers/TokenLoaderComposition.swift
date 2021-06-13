//
//  TokenLoaderComposition.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyFramework

public final class TokenLoaderComposition: TokenLoader {
    private let store: KeychainTokenStore
    private let remoteTokenLoader: RemoteTokenLoader
    private let currentDate: () -> Date
    private var pendingRequests = [(TokenSaverResult) -> Void]()
    
    public init(store: KeychainTokenStore, remoteTokenLoader: RemoteTokenLoader, currentDate: @escaping () -> Date) {
        self.store = store
        self.remoteTokenLoader = remoteTokenLoader
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (TokenSaverResult) -> Void) {
        store.load {[weak self] tokenResult in
            guard let self = self else {return}
            switch tokenResult {
            case let .success(token) where self.isValidToken(token):
                completion(.success(token))
            case let .success(expiredToken):
                self.pendingRequests.append(completion)
                
                guard self.pendingRequests.count == 1 else {return}

                self.requestNewToken(with: expiredToken, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
        
    private func requestNewToken(with expiredToken: Token, completion: @escaping (TokenSaverResult) -> Void) {
        remoteTokenLoader.load(withRefreshToken: expiredToken.refreshToken) {[weak self] newTokenResult in
            guard let self = self else {return}
            switch newTokenResult {
            case let .success(newToken):
                self.pendingRequests.forEach { $0(.success(newToken)) }
            case let .failure(error):
                self.pendingRequests.forEach { $0(.failure(error)) }
            }
            
            self.pendingRequests = []
        }
        
    }
    
    private func isValidToken(_ token: Token) -> Bool {
        token.expiredDate > self.currentDate()
    }
}
