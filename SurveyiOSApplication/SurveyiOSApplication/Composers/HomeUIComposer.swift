//
//  HomeUIComposer.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import UIKit

public final class HomeUIComposer {
    private init() {}
    
    public static func homeComposedWith(delegate: HomeViewControllerDelegate, currentDate:  @escaping () -> Date) -> HomeViewController {
        let bundle = Bundle(for: HomeViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeViewController: HomeViewController = storyboard.instantiate()
        homeViewController.delegate = MainQueueDispatchDecorator(decoratee: delegate)
        homeViewController.currentDate = currentDate
        
        return homeViewController
    }
    
}

private final class MainQueueDispatchDecorator: HomeViewControllerDelegate {
    private let decoratee: HomeViewControllerDelegate

    init(decoratee: HomeViewControllerDelegate) {
        self.decoratee = decoratee
    }

    func loadSurvey(completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void) {
        decoratee.loadSurvey { result in
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
