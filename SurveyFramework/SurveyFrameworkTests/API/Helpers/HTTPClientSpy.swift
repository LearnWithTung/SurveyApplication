//
//  HTTPClientSpy.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation
import SurveyFramework

class HTTPClientSpy: HTTPClient {    
    private var messages = [(urlRequest: URLRequest,
                             completion: (HTTPClient.HTTPClientResult) -> Void)]()
    
    var requestedURLRequests: [URLRequest] {
        return messages.map {$0.urlRequest}
    }
    
    var requestedURLs: [URL] {
        return requestedURLRequests.map{$0.url!}
    }
    
    func request(from url: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0){
        messages[index].completion(.failure(error))
    }
    
    func completeWithStatusCode(_ code: Int, data: Data = Data(), at index: Int = 0) {
        let httpResponse = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, httpResponse)))
    }
    
}
