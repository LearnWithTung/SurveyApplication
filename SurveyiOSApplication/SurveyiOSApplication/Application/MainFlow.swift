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
    private let surveyDetailFlow: Flow
    
    public init(navController: UINavigationController,
                delegate: HomeViewControllerDelegate,
                imageLoader: SurveyImageDataLoader,
                currentDate: @escaping () -> Date,
                surveyDetailFlow: Flow) {
        self.navController = navController
        self.delegate = delegate
        self.imageLoader = imageLoader
        self.currentDate = currentDate
        self.surveyDetailFlow = surveyDetailFlow
    }
    
    public func start(){
        let vc = HomeUIComposer.homeComposedWith(delegate: delegate, imageLoader: imageLoader, currentDate: currentDate)
        
        vc.toSurveyDetails = { [weak self] in
            self?.surveyDetailFlow.start()
        }
        
        navController.setViewControllers([vc], animated: true)
    }
    
}