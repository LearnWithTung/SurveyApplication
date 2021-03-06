//
//  HomeUIComposer.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import UIKit

public final class HomeUIComposer {
    private init() {}
    
    public static func viewControllerComposedWith(delegate: HomeViewControllerDelegate, imageLoader: SurveyImageDataLoader, currentDate:  @escaping () -> Date, onLogoutRequest: @escaping (() -> Void)) -> HomeViewController {
        let bundle = Bundle(for: HomeViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeViewController: HomeViewController = storyboard.instantiate()
        homeViewController.delegate = MainQueueDispatchDecorator(decoratee: delegate)
        homeViewController.currentDate = currentDate
        
        homeViewController.onViewDidLoad = { [weak homeViewController] in
            homeViewController?.surveyViewController.imageLoader = imageLoader
        }
        
        homeViewController.onLogoutRequest = onLogoutRequest
        
        return homeViewController
    }
    
}
