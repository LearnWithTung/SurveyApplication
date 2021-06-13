//
//  TestHelpers.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyFramework

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func makeTokenWith(expiredDate: Date, refreshToken: String = "any") -> Token {
    Token(accessToken: "any", tokenType: "any", expiredDate: expiredDate, refreshToken: refreshToken)
}

func anyNSError() -> NSError {
    NSError(domain: "test", code: 0, userInfo: nil)
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URLRequest]()
    private var completions = [(HTTPClientResult) -> Void]()
    
    func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        requestedURLs.append(url)
        completions.append(completion)
    }
    
    func complete(with values: (data: Data, response: HTTPURLResponse), at index: Int = 0) {
        completions[index](.success(values))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}
