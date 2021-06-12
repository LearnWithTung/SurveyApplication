//
//  HomeViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public struct RepresentationSurvey {
    let title: String
    let description: String
    let imageURL: URL
    
    public init(title: String, description: String, imageURL: URL) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
    }
}

public protocol HomeViewControllerDelegate {
    func loadSurvey(completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void)
}

public class SurveyViewController {
    public var surveyModels = [RepresentationSurvey]()

}

public class HomeViewController: UIViewController {
    private var currentDate: (() -> Date)?
    private var delegate: HomeViewControllerDelegate?
    public let loadingView =  UIView()
    public let surveyViewController = SurveyViewController()
    public let dateLabel = UILabel()
    
    public convenience init(delegate: HomeViewControllerDelegate, currentDate: @escaping () -> Date) {
        self.init()
        self.delegate = delegate
        self.currentDate = currentDate
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        
        dateLabel.text = currentDate?().dateStringWithFormat("EEEE, MMM d")
    }
    
    public func refresh() {
        load()
    }
    
    private func load() {
        loadingView.isHidden = false
        
        delegate?.loadSurvey {[weak self] result in
            self?.loadingView.isHidden = true
            if let surveys = try? result.get() {
                self?.surveyViewController.surveyModels = surveys
            }
        }
    }
}
