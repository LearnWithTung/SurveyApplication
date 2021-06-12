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
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias RemoteLoginResult = Result<Token, Error>
    
    public init(url: URL, client: HTTPClient, credentials: Credentials, currentDate: @escaping () -> Date) {
        self.client = client
        self.url = url
        self.credentials = credentials
        self.currentDate = currentDate
    }
    
    public func load(with info: LoginInfo, completion: @escaping (RemoteLoginResult) -> Void) {
        client.request(from: makeURLRequest(with: info)) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success((data, response)):
                completion(RemoteLoginMappers.map(data: data, response: response, currentDate: self.currentDate()))
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
