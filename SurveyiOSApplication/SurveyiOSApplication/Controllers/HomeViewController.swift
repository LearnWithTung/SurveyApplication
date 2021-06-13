//
//  HomeViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public protocol HomeViewControllerDelegate {
    func loadSurvey(pageNumber: Int, pageSize: Int, completion: @escaping (Result<[RepresentationSurvey], Error>) -> Void)
}

public class HomeViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var currentDate: (() -> Date)?
    var delegate: HomeViewControllerDelegate?
    var onViewDidLoad: (() -> Void)?
    var toSurveyDetails: (() -> Void)?
    
    @IBOutlet public private(set) var loadingView: LoadingView!
    @IBOutlet public private(set) var dateLabel: UILabel!
    
    public private(set) var surveyViewController: SurveyViewController!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()

        load()
        
        dateLabel.text = currentDate?().dateStringWithFormat("EEEE, MMM d").uppercased()
    }
    
    private func refresh() {
        loadingView.showIndicator()
        load()
    }
    
    private func load() {
        loadingView.isHidden = false
        
        delegate?.loadSurvey(pageNumber: 1, pageSize: 5) {[weak self] result in
            self?.loadingView.isHidden = true
            if let surveys = try? result.get() {
                self?.surveyViewController.surveyModels = surveys
            }
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SurveyViewController", let viewController = segue.destination as? SurveyViewController {
            self.surveyViewController = viewController
            self.surveyViewController.onRefresh = {[weak self] in
                self?.refresh()
            }
            self.surveyViewController.onSurveyDetails = {[weak self] in
                self?.toSurveyDetails?()
            }
        }
    }
}
