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

public class SurveyViewController: UIViewController {
    public var surveyModels = [RepresentationSurvey]()

}

public class HomeViewController: UIViewController {
    var currentDate: (() -> Date)?
    var delegate: HomeViewControllerDelegate?
    
    @IBOutlet public private(set) var loadingView: LoadingView!
    @IBOutlet public private(set) var dateLabel: UILabel!
    
    public var surveyViewController: SurveyViewController!
    
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
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SurveyViewController", let viewController = segue.destination as? SurveyViewController {
            self.surveyViewController = viewController
        }
    }
}
