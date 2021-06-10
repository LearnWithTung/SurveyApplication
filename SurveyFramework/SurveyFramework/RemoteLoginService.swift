//
//  RemoteLoginService.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public struct LoginInfo {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public class RemoteLoginService {
    private let url: URL
    private let client: HTTPClient
    private let credentials: Credentials
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient, credentials: Credentials) {
        self.client = client
        self.url = url
        self.credentials = credentials
    }
    
    public func login(with info: LoginInfo, completion: @escaping (Result<Void, Error>) -> Void = {_ in}) {
        client.post(with: makeURLRequest(with: info)) { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success((data, _)):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    return completion(.success(()))
                }
                completion(.failure(.invalidData))
            }
        }
    }
    
    private func makeURLRequest(with info: LoginInfo) -> URLRequest {
        let body = [
            "grant_type": "password",
            "email": info.email,
            "password": info.password,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        return request
    }
}
