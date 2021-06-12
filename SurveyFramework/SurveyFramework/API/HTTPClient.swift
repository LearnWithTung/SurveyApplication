//
//  HTTPClient.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>
    func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}

