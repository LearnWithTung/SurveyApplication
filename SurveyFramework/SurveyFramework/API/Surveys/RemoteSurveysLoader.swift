//
//  RemoteSurveysLoader.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

public struct SurveyQuery {
    public let pageNumber: Int
    public let pageSize: Int
    
    public init(pageNumber: Int, pageSize: Int) {
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
}

public final class RemoteSurveysLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(query: SurveyQuery, completion: @escaping (Result<[Survey], Error>) -> Void) {
        let request = makeRequest(from: query)
        client.get(from: request) {[weak self] result in
            guard self != nil else {return}
            
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success((data, response)):
                completion(RemoteSurveysMappers.map(data, response))
            }
        }
    }
    
    private func makeRequest(from query: SurveyQuery) -> URLRequest {
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(query.pageNumber)"),
            URLQueryItem(name: "page[size]", value: "\(query.pageSize)")
        ]
        
        let enrichURL = urlComponent.url!
        return URLRequest(url: enrichURL)
    }
    
}
