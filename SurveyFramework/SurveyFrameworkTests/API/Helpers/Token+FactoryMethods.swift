//
//  Token+FactoryMethods.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation

func makeTokenJSONData(from dict: [String: Any]) -> Data {
    let json = ["data": ["attributes": dict]]

    return try! JSONSerialization.data(withJSONObject: json)
}
