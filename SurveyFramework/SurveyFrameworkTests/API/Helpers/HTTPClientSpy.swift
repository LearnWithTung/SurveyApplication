//
//  HTTPClientSpy.swift
//  SurveyFrameworkTests
//
//  Created by Tung Vu on 10/06/2021.
//

import Foundation
import SurveyFramework

class HTTPClientSpy: HTTPClient {
    // MARK: - Load
    
    private var messages = [(urlRequest: URLRequest,
                             completion: (HTTPClient.HTTPClientResult) -> Void)]()
    
    var requestedURLRequests: [URLRequest] {
        return messages.map {$0.urlRequest}
    }
    
    var requestedURLs: [URL] {
        return requestedURLRequests.map{$0.url!}
    }
    
    func post(with request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
        messages.append((request, completion))
    }
    
    func completeWithError(_ error: Error, at index: Int = 0){
        messages[index].completion(.failure(error))
    }
    
    func completeWithStatusCode(_ code: Int, data: Data = Data(), at index: Int = 0) {
        let httpResponse = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, httpResponse)))
    }
    
    // MARK: - Get
    var requestedGETURLRequests = [URLRequest]()
    
    func get(from request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
        requestedGETURLRequests.append(request)
        messages.append((request, completion))
    }
    
}
