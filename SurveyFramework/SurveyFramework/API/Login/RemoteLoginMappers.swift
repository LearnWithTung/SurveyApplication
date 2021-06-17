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
        if response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data), let models = try? root.data.attributes.toModel(currentDate: currentDate) {
            return .success(models)
        }
        return .failure(RemoteLoginService.Error.invalidData)
    }
}
