//
//  TokenLoader.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public typealias TokenLoadCompletion = (TokenLoader.TokenSaverResult) -> Void
public protocol TokenLoader {
    typealias TokenSaverResult = Result<Token, Swift.Error>
    func load(completion: @escaping (Result<Token, Swift.Error>) -> Void)
}
