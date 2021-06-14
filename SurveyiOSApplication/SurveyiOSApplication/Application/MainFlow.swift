//
//  MainFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit
import SurveyFramework

public final class MainFlow: Flow {
    private let navController: UINavigationController
    private let delegate: HomeViewControllerDelegate
    private let store: TokenCleaner
    private let currentDate: () -> Date
    private let imageLoader: SurveyImageDataLoader
    private let surveyDetailFlow: Flow
    var onLogout: (() -> Void)?
    
    public init(navController: UINavigationController,
                delegate: HomeViewControllerDelegate,
                store: TokenCleaner,
                imageLoader: SurveyImageDataLoader,
                currentDate: @escaping () -> Date,
                surveyDetailFlow: Flow) {
        self.navController = navController
        self.delegate = delegate
        self.store = store
        self.imageLoader = imageLoader
        self.currentDate = currentDate
        self.surveyDetailFlow = surveyDetailFlow
    }
    
    public func start(){
        let vc = HomeUIComposer.homeComposedWith(delegate: delegate, imageLoader: imageLoader, currentDate: currentDate) { [weak self] in
            self?.store.clear()
            self?.onLogout?()
        }
        
        vc.toSurveyDetails = { [weak self] in
            self?.surveyDetailFlow.start()
        }
        
        navController.setViewControllers([vc], animated: true)
    }
}
