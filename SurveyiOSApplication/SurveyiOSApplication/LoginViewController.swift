//
//  LoginViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public protocol LoginViewControllerDelegate {}

public class LoginViewController: UIViewController {
    var delegate: LoginViewControllerDelegate?
    
    @IBOutlet public private(set) weak var emailTextField: UITextField!
    @IBOutlet public private(set) weak var passwordTextField: UITextField!
    @IBOutlet public private(set) weak var loginButton: UIButton!
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {}
}
