//
//  SideMenuView.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 14/06/2021.
//

import UIKit

public class SideMenuView: UIView {
    
    @IBOutlet public private(set) weak var logoutButton: UIButton!
    @IBOutlet weak var viewContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: UIView!
    var onDismiss: (() -> Void)?
    var onLogout: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissMenu() {
        onDismiss?()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        onLogout?()
    }
    
    private func customInit(){
        let contentView = UINib(nibName: "SideMenuView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func animateMenu(isHidden: Bool) {
        self.isHidden = false
        alpha = isHidden ? 1 : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.alpha = isHidden ? 0 : 1
            self.viewContainerLeadingConstraint.constant = isHidden ? 0 : self.viewContainer.bounds.width
            self.layoutIfNeeded()
        }
    }
    
}
