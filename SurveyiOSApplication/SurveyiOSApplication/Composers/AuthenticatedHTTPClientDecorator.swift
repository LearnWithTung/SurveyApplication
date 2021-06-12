//
//  AuthenticatedHTTPClientDecorator.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import Foundation
import SurveyFramework

public final class AuthenticatedHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let service: TokenLoader
    private var pendingTokenRequests = [TokenLoadCompletion]()
    
    public init(decoratee: HTTPClient, service: TokenLoader) {
        self.decoratee = decoratee
        self.service = service
    }
    
    public func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        var signedRequest = url
        pendingTokenRequests.append {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(token):
                signedRequest.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
                self.decoratee.request(from: signedRequest, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        guard pendingTokenRequests.count == 1 else {return}
        
        service.load {[weak self] tokenResult in
            self?.pendingTokenRequests.forEach { $0(tokenResult) }
            self?.pendingTokenRequests = []
        }
    }
    
}
