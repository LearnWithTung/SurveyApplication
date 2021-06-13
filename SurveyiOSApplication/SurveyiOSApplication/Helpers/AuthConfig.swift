//
//  AuthConfig.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation

func getConfig<T: Decodable>(fromPlist resource: String) -> T {
  guard
    let path = Bundle.main.path(forResource: resource, ofType: "plist"),
    let xml = FileManager.default.contents(atPath: path),
    let config = try? PropertyListDecoder().decode(T.self, from: xml)
    else { fatalError("Expected to find \(resource).plist but got nil instead") }
  return config
}

struct AuthConfig: Decodable {
    let client_id: String
    let client_secret: String

}

struct Configurations {
    private static let baseURLString: String? = Bundle.main.infoDictionary?["baseURL"] as? String
    
    static var baseURL: URL? {
        return URL(string: baseURLString ?? "")
    }
}
