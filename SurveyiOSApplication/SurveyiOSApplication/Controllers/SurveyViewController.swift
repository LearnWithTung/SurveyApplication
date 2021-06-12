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
    private(set) var currentIndex: Int = 0
    var imageLoader: SurveyImageDataLoader?
    private var task: ImageDataTask?
    
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
        if currentIndex >= surveyModels.count - 1 {return}
        currentIndex += 1
        setupContent(for: surveyModels[currentIndex])
    }
    
    func previous() {
        if currentIndex == 0 {return}
        currentIndex -= 1
        setupContent(for: surveyModels[currentIndex])
    }
    
    private func resetContent() {
        currentIndex = 0
        backgroundImageView.image = nil
        descriptionLabel.text = nil
        titleLabel.text = nil
        pageControl.numberOfPages = 0
        cancelImageLoad()
    }
    
    private func setupContent(for model: RepresentationSurvey) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        pageControl.currentPage = currentIndex
        cancelImageLoad()
        task = imageLoader?.load(from: model.imageURL) {[weak self] result in
            self?.backgroundImageView.image = (try? result.get()).flatMap(UIImage.init)
        }
    }
    
    private func cancelImageLoad() {
        task?.cancel()
        task = nil
    }

}
