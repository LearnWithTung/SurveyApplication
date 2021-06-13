//
//  MainQueueDispatchDecorator.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import Foundation

public final class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    
    public init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
    
}

extension MainQueueDispatchDecorator: HomeViewControllerDelegate where T == HomeViewControllerDelegate {
    public func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
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

extension MainQueueDispatchDecorator: Flow where T == Flow {
    public func start() {
        if Thread.isMainThread {
            decoratee.start()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.decoratee.start()
            }
        }
    }
}
