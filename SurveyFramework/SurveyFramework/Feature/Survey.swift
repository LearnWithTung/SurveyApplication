//
//  Survey.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public struct Survey {
    let id: String
    let attributes: Attributes
}

public struct Attributes {
    let title: String
    let description: String
    let imageURL: String
}
