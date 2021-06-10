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
    
    public init(url: URL, client: HTTPClient, credentials: Credentials, currentDate: @escaping () -> Date) {
        self.client = client
        self.url = url
        self.credentials = credentials
        self.currentDate = currentDate
    }
    
    public func login(with info: LoginInfo, completion: @escaping (Result<Token, Error>) -> Void = {_ in}) {
        client.post(with: makeURLRequest(with: info)) { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success((data, _)):
                if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    let localToken = root.attributes
                    let calendar = Calendar(identifier: .gregorian)
                    let expiredDate = calendar.date(byAdding: .second, value: localToken.expires_in, to: self.currentDate())!
                    let token = Token(accessToken: localToken.access_token, tokenType: localToken.token_type, expiredDate: expiredDate, refreshToken: localToken.refresh_token)
                    return completion(.success(token))
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

private struct Root: Decodable {
    let attributes: RemoteToken
    
    struct RemoteToken: Decodable {
        let access_token: String
        let token_type: String
        let expires_in: Int
        let refresh_token: String
        
        func toModel() -> Token {
            let calendar = Calendar(identifier: .gregorian)
            let expiredDate = calendar.date(byAdding: .second, value: expires_in, to: Date())!
            
            return Token(accessToken: access_token, tokenType: token_type, expiredDate: expiredDate, refreshToken: refresh_token)
        }
    }
}
