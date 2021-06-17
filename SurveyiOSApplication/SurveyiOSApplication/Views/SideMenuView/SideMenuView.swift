//
//  SideMenuView.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 14/06/2021.
//

import UIKit

public class SideMenuView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet public private(set) weak var logoutButton: UIButton!
    @IBOutlet weak var viewContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: UIView!
    var onDismiss: (() -> Void)?
    var onLogout: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        onLogout?()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = hitTest(firstTouch.location(in: self), with: event)
            if hitView == backgroundView {
                onDismiss?()
            }
        }
    }
    
    
    private func customInit(){
        let contentView = UINib(nibName: "SideMenuView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = bounds
    }
    
    func animateMenu(isHidden: Bool) {
        if isHidden {
            animateOut()
        } else {
            animateIn()
        }
    }
    
    private func animateIn() {
        self.isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.alpha =  1
            self.viewContainerLeadingConstraint.constant = self.viewContainer.bounds.width
            self.layoutIfNeeded()
        }
    }
    
    private func animateOut() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.viewContainerLeadingConstraint.constant = 0
            self.layoutIfNeeded()
        }) { _ in
            self.alpha = 0
        }
    }
    
}
