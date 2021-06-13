//
//  LoginService.swift
//  SurveyFramework
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation

public protocol LoginService {
    typealias LoginResult = Result<Token, Error>
    func load(with info: LoginInfo, completion: @escaping (LoginResult) -> Void)
}
