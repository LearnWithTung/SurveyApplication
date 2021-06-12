//
//  HomeViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public struct RepresentationSurvey {}

public protocol HomeViewControllerDelegate {
    func loadSurvey(completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void)
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
        
        load()
    }
    
    public func refresh() {
        load()
    }
    
    private func load() {
        loadingView.isHidden = false
        
        delegate?.loadSurvey {[weak self] _ in
            self?.loadingView.isHidden = true
        }
    }
}
