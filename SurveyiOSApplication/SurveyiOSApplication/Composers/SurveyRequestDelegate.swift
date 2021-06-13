//
//  SurveyRequestDelegate.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import SurveyFramework

public class SurveyRequestDelegate: HomeViewControllerDelegate {
    private let loader: SurveyLoader
    
    public init(loader: SurveyLoader) {
        self.loader = loader
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
    
}

private extension Array where Element == Survey {
    
    func toRepresentation() -> [RepresentationSurvey] {
        self.map {
            RepresentationSurvey(title: $0.attributes.title, description: $0.attributes.description, imageURL: $0.attributes.imageURL.appendingPathComponent("l"))
        }
    }
    
}
