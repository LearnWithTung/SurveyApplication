//
//  SurveyRequestDelegate.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyFramework

public class SurveyRequestDelegate: HomeViewControllerDelegate {
    private let loader: SurveyLoader
    private let didCompleteLogin: () -> Void
    
    public init(loader: SurveyLoader, didCompleteLogin: @escaping () -> Void) {
        self.loader = loader
        self.didCompleteLogin = didCompleteLogin
    }
    
    public func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
        loader.load(query: .init(pageNumber: pageNumber, pageSize: pageSize)) {[weak self] result in
            guard self != nil else {return}
            
            switch result {
            case let .success(surveys):
                completion(.success(surveys.toRepresentation()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func navigateToSurveyDetails() {
        didCompleteLogin()
    }
    
}

private extension Array where Element == Survey {
    
    func toRepresentation() -> [RepresentationSurvey] {
        map {
            let originalURLString = $0.attributes.imageURL.absoluteString
            let newURL = URL(string: originalURLString + "l")!
            return RepresentationSurvey(title: $0.attributes.title, description: $0.attributes.description, imageURL: newURL)
        }
    }
    
}
