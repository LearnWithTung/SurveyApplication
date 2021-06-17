//
//  CustomPageControl.swift
//  Prototype
//
//  Created by Tung Vu on 12/06/2021.
//

import UIKit

class CustomPageControl: UIView {
    
    @IBOutlet private weak var stackViewContainer: UIStackView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
    }
    
    @IBInspectable
    var numberOfPages: Int = 3 {
        didSet {
            currentIndex = 0
            updateDots()
        }
    }
    
    private var currentIndex: Int = 0
    
    @IBInspectable
    var currentPage: Int {
        get {
            return currentIndex
        }
        set {
            currentIndex = newValue
            updateCurrentPage()
        }
    }
    
    private func customInit(){
        let contentView = UINib(nibName: "CustomPageControl", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    private func updateDots() {
        stackViewContainer.arrangedSubviews.forEach {$0.removeFromSuperview()}
        
        for i in 0..<numberOfPages {
            let containerView = UIView()
            containerView.backgroundColor = i == currentIndex ? .white : .lightGray
            containerView.alpha = i == currentPage ? 1 : 0.5
            containerView.layer.cornerRadius = 4
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: 8).isActive = true
            
            stackViewContainer.addArrangedSubview(containerView)
        }
        
        let dummyView = UIView()
        stackViewContainer.addArrangedSubview(dummyView)
    }
    
    private func updateCurrentPage() {
        for i in 0..<stackViewContainer.arrangedSubviews.count {
            stackViewContainer.arrangedSubviews[i].backgroundColor = .lightGray
            stackViewContainer.arrangedSubviews[i].alpha = i == currentIndex ? 1 : 0.5
            if i == currentIndex {
                stackViewContainer.arrangedSubviews[i].backgroundColor = .white
            }
            if i == stackViewContainer.arrangedSubviews.count - 1 {
                stackViewContainer.arrangedSubviews[i].backgroundColor = .clear
            }
        }
    }
}
