//
//  HomeViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public protocol HomeViewControllerDelegate {
    func loadSurvey()
}

public class HomeViewController: UIViewController {
    private var delegate: HomeViewControllerDelegate?
    public let loadingView =  UIView()
    
    public convenience init(delegate: HomeViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate?.loadSurvey()
    }
    
    public func refresh() {
        delegate?.loadSurvey()
    }
}
