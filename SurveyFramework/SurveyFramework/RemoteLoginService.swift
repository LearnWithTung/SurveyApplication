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

public struct Credentials {
    public let client_id: String
    public let client_secret: String
    
    public init(client_id: String, client_secret: String) {
        self.client_id = client_id
        self.client_secret = client_secret
    }
}

public class RemoteLoginService {
    private let url: URL
    private let client: HTTPClient
    private let credentials: Credentials
    
    public init(url: URL, client: HTTPClient, credentials: Credentials) {
        self.client = client
        self.url = url
        self.credentials = credentials
    }
    
    public func login(with info: LoginInfo) {
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
        
        client.post(with: request)
    }
}

public protocol HTTPClient {
    func post(with request: URLRequest)
}
