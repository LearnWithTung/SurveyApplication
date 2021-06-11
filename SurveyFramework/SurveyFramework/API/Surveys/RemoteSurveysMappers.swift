//
//  RemoteSurveysMappers.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

final class RemoteSurveysMappers {
    private struct Root: Decodable {
        let data: [RemoteSurvey]
        
        struct RemoteSurvey: Decodable {
            let id: String
            let attributes: RemoteAttributes
            
            var model: Survey {
                return Survey(id: id,
                              attributes: Attributes(title: attributes.title, description: attributes.description, imageURL: attributes.cover_image_url))
            }
        }
        
        struct RemoteAttributes: Decodable {
            let title: String
            let description: String
            let cover_image_url: URL
        }
    }
    
    private init() {}

    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result<[Survey], RemoteSurveysLoader.Error> {
        if response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.data.map {$0.model})
        }
        return .failure(.invalidData)
    }
}
