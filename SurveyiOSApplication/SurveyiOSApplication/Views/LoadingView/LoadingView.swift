//
//  LoadingView.swift
//  Prototype
//
//  Created by Tung Vu on 09/06/2021.
//

import UIKit

public class LoadingView: UIView {
    
    @IBOutlet weak var indicatorLoadingView: UIView!
    @IBOutlet weak var skeletonLoadingView: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        skeletonLoadingView.subviews.forEach {$0.layer.cornerRadius = $0.frame.height / 2}
        skeletonLoadingView.subviews.forEach {$0.isShimmering = true}
    }
    
    private func customInit(){
        let contentView = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func showIndicator() {
        skeletonLoadingView.isHidden = true
        indicatorLoadingView.isHidden = false
    }
    
    func showSkeleton() {
        skeletonLoadingView.isHidden = false
        indicatorLoadingView.isHidden = true
    }

}
