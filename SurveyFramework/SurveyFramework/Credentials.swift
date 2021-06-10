//
//  Credentials.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public struct Credentials {
    public let client_id: String
    public let client_secret: String
    
    public init(client_id: String, client_secret: String) {
        self.client_id = client_id
        self.client_secret = client_secret
    }
}
