//
//  SurveyDetailFlow.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit

public final class SurveyDetailFlow: Flow {
    private let navController: UINavigationController

    public init(navController: UINavigationController) {
        self.navController = navController
    }
    
    public func start() {
        let bundle = Bundle(for: SurveyDetailViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let surveyDetailVC: SurveyDetailViewController = storyboard.instantiate()

        navController.pushViewController(surveyDetailVC, animated: true)
    }
    
}
