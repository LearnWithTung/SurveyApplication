//
//  SurveyViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
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

public class SurveyViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControl: CustomPageControl!
    private var currentIndex: Int = 0
    
    public var surveyModels = [RepresentationSurvey]() {
        didSet {
            resetContent()
            if !surveyModels.isEmpty {
                pageControl.numberOfPages = surveyModels.count
                setupContent(for: surveyModels[0])
            }
        }
    }
    
    func next() {
        currentIndex += 1
        setupContent(for: surveyModels[currentIndex])
    }
    
    private func resetContent() {
        backgroundImageView.image = nil
        descriptionLabel.text = nil
        titleLabel.text = nil
        pageControl.numberOfPages = 0
    }
    
    private func setupContent(for model: RepresentationSurvey) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }

}
