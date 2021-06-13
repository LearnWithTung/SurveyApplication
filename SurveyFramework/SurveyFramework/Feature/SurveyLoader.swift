//
//  SurveyLoader.swift
//  SurveyFramework
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation

public protocol SurveyLoader {
    typealias LoadSurveyResult = Result<[Survey], Error>
    func load(query: SurveyQuery, completion: @escaping (LoadSurveyResult) -> Void)
}
