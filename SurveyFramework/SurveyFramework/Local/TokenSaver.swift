//
//  TokenSaver.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public protocol TokenSaver {
    typealias TokenSaverResult = Result<Void, Swift.Error>
    func save(token: Token, completion: @escaping (TokenSaverResult) -> Void)
}
