//
//  MainQueueDispatchDecorator.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import Foundation

final class MainQueueDispatchDecorator: HomeViewControllerDelegate {
    private let decoratee: HomeViewControllerDelegate

    init(decoratee: HomeViewControllerDelegate) {
        self.decoratee = decoratee
    }

    func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
        decoratee.loadSurvey(pageNumber: pageNumber, pageSize: pageSize) { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
