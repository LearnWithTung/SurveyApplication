//
//  HTTPClient.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public protocol HTTPClient {
    func post(with request: URLRequest)
}

