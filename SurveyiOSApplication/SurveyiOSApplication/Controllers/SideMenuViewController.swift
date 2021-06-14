//
//  SideMenuViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 14/06/2021.
//

import UIKit

public class SideMenuViewController: UIViewController {
    
    var onLogout: (() -> Void)?
    @IBOutlet public private(set) weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        onLogout?()
    }
}
