//
//  HomeViewControllerDelegateSpy.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 14/06/2021.
//

import Foundation
import SurveyiOSApplication

class HomeViewControllerDelegateSpy: HomeViewControllerDelegate {
    var requestLoadSurveysCallCount: Int = 0
    private var completions = [(Result<[RepresentationSurvey], Error>) -> Void]()
    
    func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
        requestLoadSurveysCallCount += 1
        completions.append(completion)
    }
    
    func completeLoadingSurveySuccess(with surveys: [RepresentationSurvey], at index: Int = 0) {
        completions[index](.success(surveys))
    }
    
    func completeLoadingSurveyWithError(_ error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}
