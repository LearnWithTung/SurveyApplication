//
//  Survey.swift
//  SurveyFramework
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation

public struct Survey {
    public let id: String
    public let attributes: Attributes
    
    public init(id: String, attributes: Attributes) {
        self.id = id
        self.attributes = attributes
    }
}

public struct Attributes {
    public let title: String
    public let description: String
    public let imageURL: String
    
    public init(title: String, description: String, imageURL: String) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
    }
}
