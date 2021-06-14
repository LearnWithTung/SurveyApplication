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
    
    @IBOutlet public private(set) weak var loadingView: LoadingView!
    @IBOutlet public private(set) weak var dateLabel: UILabel!
    @IBOutlet public private(set) weak var sideMenuView: SideMenuView!

    public private(set) var surveyViewController: SurveyViewController!
    
    public var onLogoutRequest: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()

        load()
        
        setupLayout()
    }
    
    @IBAction func showMenuButtonTapped(_ sender: Any) {
        sideMenuView.animateMenu(isHidden: false)
    }
    
    private func setupLayout() {
        dateLabel.text = currentDate?().dateStringWithFormat("EEEE, MMM d").uppercased()
        sideMenuView.onDismiss = { [weak self] in
            self?.sideMenuView.animateMenu(isHidden: true)
        }
        sideMenuView.onLogout = onLogoutRequest
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
