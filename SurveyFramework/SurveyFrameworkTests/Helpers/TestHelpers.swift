//
//  TestHelpers.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation
import SurveyFramework

func makeToken(accessToken: String = "any", tokenType: String = "any", expiredDate: Date = Date(), refreshToken: String = "any") -> Token {
    Token(accessToken: accessToken,
          tokenType: tokenType,
          expiredDate: expiredDate,
          refreshToken: refreshToken)
}
