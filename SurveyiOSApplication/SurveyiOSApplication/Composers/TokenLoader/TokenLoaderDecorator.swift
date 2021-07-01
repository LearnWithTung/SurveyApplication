//
//  TokenLoaderComposition.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyFramework

public final class TokenLoaderDecorator: TokenLoader {
    private let store: KeychainTokenStore
    private let remoteTokenLoader: RemoteTokenLoader
    private let currentDate: () -> Date
    private var pendingRequests = [(TokenSaverResult) -> Void]()
    private let queue = DispatchQueue(label: "TokenLoaderComposition.serialQueue")
    
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
                self.queue.sync {
                    self.pendingRequests.append(completion)
                    
                    guard self.pendingRequests.count == 1 else {return}

                    self.requestNewToken(with: expiredToken) {[weak self] result in
                        if let newToken = try? result.get() {
                            self?.store.save(token: newToken) {_ in}
                        }
                        self?.pendingRequests.forEach { $0(result) }
                        self?.pendingRequests = []
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
        
    private func requestNewToken(with expiredToken: Token, completion: @escaping (TokenSaverResult) -> Void) {
        remoteTokenLoader.load(withRefreshToken: expiredToken.refreshToken) {[weak self] newTokenResult in
            guard self != nil else {return}
            switch newTokenResult {
            case let .success(newToken):
                completion(.success(newToken))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
    }
    
    private func isValidToken(_ token: Token) -> Bool {
        token.expiredDate > currentDate()
    }
}
