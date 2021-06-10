//
//  HTTPClient.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<HTTPURLResponse, Error>
    func post(with request: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}

