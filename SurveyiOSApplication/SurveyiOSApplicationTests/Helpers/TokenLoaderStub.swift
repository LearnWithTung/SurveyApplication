//
//  TokenLoaderStub.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import SurveyFramework

class TokenLoaderStub: TokenLoader {
    var stubbedToken: Token?
    var stubbedError: Error?
    
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
