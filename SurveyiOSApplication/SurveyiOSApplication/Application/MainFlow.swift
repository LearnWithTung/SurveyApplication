//
//  MainFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit

public final class MainFlow: Flow {
    private let navController: UINavigationController
    private let delegate: HomeViewControllerDelegate
    private let currentDate: () -> Date
    private let imageLoader: SurveyImageDataLoader
    
    public init(navController: UINavigationController,
                delegate: HomeViewControllerDelegate,
                imageLoader: SurveyImageDataLoader,
                currentDate: @escaping () -> Date) {
        self.navController = navController
        self.delegate = delegate
        self.imageLoader = imageLoader
        self.currentDate = currentDate
    }
    
    public func start(){
        if Thread.isMainThread {
            let vc = HomeUIComposer.homeComposedWith(delegate: delegate, imageLoader: imageLoader, currentDate: currentDate)
            
            navController.setViewControllers([vc], animated: true)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                let vc = HomeUIComposer.homeComposedWith(delegate: self.delegate, imageLoader: self.imageLoader, currentDate: self.currentDate)
                
                self.navController.setViewControllers([vc], animated: true)
            }
        }
    }
    
}
