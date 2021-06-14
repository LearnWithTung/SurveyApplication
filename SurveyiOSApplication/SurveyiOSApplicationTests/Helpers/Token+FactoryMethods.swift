//
//  Token+FactoryMethods.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 14/06/2021.
//

import Foundation
import SurveyFramework

func anyNonExpirationToken(currentDate: Date) -> Token {
    let validDate = currentDate.adding(seconds: 1)
    return makeTokenWith(expiredDate: validDate)
}
