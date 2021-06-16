//
//  AlamofireRefreshTokenDecorator.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 16/06/2021.
//

import Foundation
import Alamofire
import SurveyFramework

final class AlamofireRefreshTokenDecorator: HTTPClient {
    private let url: URL
    private let credentials: Credentials
    private let saver: TokenSaver
    private let loader: TokenLoader
    
    
    init(url: URL, credentials: Credentials, saver: TokenSaver, loader: TokenLoader) {
        self.url = url
        self.credentials = credentials
        self.saver = saver
        self.loader = loader
    }
    
    func request(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        AF.request(url).responseJSON { response in
            // mapping logic here
        }
    }
    
}

extension AlamofireRefreshTokenDecorator: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        loader.load { result in
            switch result {
            case let .success(token):
                let header = "\(token.tokenType) \(token.accessToken)"
                request.setValue(header, forHTTPHeaderField: "Authorization")
                completion(.success(urlRequest))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        refreshToken { isSuccess in
            isSuccess ? completion(.retry) : completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) {
        loader.load {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(token):
                let parameters = ["grant_type": "refresh_token",
                                  "refresh_token": token.refreshToken,
                                  "client_id": self.credentials.client_id,
                                  "client_secret": self.credentials.client_secret]
                AF.request(self.url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    if let _ = response.data {
                        // mapping logic to get the new token
                        // save the new token
                        // self.saver.save(token: newToken) {_ in}
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }
    
}
