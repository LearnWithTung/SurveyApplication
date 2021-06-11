//
//  RemoteTokenMappers.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

final class RemoteTokenMappers {

    private init() {}
    
    static func map(data: Data, response: HTTPURLResponse, currentDate: Date) -> RemoteTokenLoader.RemoteTokenResult {
        if response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.attributes.toModel(currentDate: currentDate))
        }
        return .failure(.invalidData)
    }
}
