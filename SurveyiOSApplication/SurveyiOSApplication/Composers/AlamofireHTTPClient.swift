//
//  AlamofireHTTPClient.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import SurveyFramework
import Alamofire

class AlamofireHTTPClient: HTTPClient {
    
    func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        AF.request(url).responseJSON { result in
            if let error = result.error {
                return completion(.failure(error))
            }
            if let data = result.data, let response = result.response {
                return completion(.success((data, response)))
            }
        }
    }
    
}
