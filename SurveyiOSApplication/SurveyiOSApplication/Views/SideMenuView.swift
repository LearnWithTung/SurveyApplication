//
//  SideMenuView.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 14/06/2021.
//

import UIKit

class SideMenuView: UIView {
    
    @IBOutlet public private(set) weak var logoutButton: UIButton!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
        
    }
    
    private func customInit(){
        let contentView = UINib(nibName: "SideMenuView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
}
