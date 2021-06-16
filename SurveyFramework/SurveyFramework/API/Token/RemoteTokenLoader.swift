//
//  RemoteTokenLoader.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

open class RemoteTokenLoader {
    private let url: URL
    private let client: HTTPClient
    private let credentials: Credentials
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias RemoteTokenResult = Result<Token, Error>
    
    public init(url: URL, client: HTTPClient, credentials: Credentials, currentDate: @escaping () -> Date) {
        self.client = client
        self.url = url
        self.credentials = credentials
        self.currentDate = currentDate
    }
    
    open func load(withRefreshToken token: String, completion: @escaping (RemoteTokenResult) -> Void) {
        client.request(from: makeURLRequest(with: token)) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success((data, response)):
                completion(RemoteTokenMappers.map(data: data, response: response, currentDate: self.currentDate()))
            }
        }
    }
    
    private func makeURLRequest(with token: String) -> URLRequest {
        let body = [
            "grant_type": "refresh_token",
            "refresh_token": token,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret
        ]
        
        var request = URLRequest(url: url)
        if let bodyData = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = bodyData
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
