//
//  RemoteToken.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

struct Root: Decodable {
    let data: SessionAttributes
    
    struct SessionAttributes: Decodable {
        let attributes: RemoteToken
    }
        
    struct RemoteToken: Decodable {
        let access_token: String
        let token_type: String
        let expires_in: Int
        let refresh_token: String
        
        enum UnexpectedError: Error {
            case invalidDate
        }
        
        func toModel(currentDate: Date) throws -> Token {
            let calendar = Calendar(identifier: .gregorian)
            guard let expiredDate = calendar.date(byAdding: .second, value: expires_in, to: currentDate) else {
                throw UnexpectedError.invalidDate
            }
            let token = Token(accessToken: access_token, tokenType: token_type, expiredDate: expiredDate, refreshToken: refresh_token)
            
            return token
        }
    }
}
