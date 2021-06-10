//
//  Token.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public struct Token {
    public let accessToken: String
    public let tokenType: String
    public let expiredDate: Date
    public let refreshToken: String
    
    public init(accessToken: String, tokenType: String, expiredDate: Date, refreshToken: String) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiredDate = expiredDate
        self.refreshToken = refreshToken
    }
}
