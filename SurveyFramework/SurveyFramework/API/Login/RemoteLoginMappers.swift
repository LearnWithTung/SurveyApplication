//
//  RemoteLoginMappers.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

final class RemoteLoginMappers {
    private init() {}
    
    static func map(data: Data, response: HTTPURLResponse, currentDate: Date) -> RemoteLoginService.RemoteLoginResult {
        if response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.attributes.toModel(currentDate: currentDate))
        }
        return .failure(.invalidData)
    }
}
