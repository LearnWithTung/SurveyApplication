//
//  Token.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

struct Token {
    let accessToken: String
    let tokenType: String
    let expiredDate: Date
    let refreshToken: String
}
