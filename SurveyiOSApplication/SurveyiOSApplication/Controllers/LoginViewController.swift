//
//  LoginViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public protocol LoginViewControllerDelegate {
    func login()
}

public class LoginViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var delegate: LoginViewControllerDelegate?
    
    @IBOutlet weak var fieldsContainer: UIStackView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet public private(set) weak var emailTextField: CustomTextField!
    @IBOutlet public private(set) weak var passwordTextField: CustomTextField!
    @IBOutlet public private(set) weak var loginButton: UIButton!
    @IBOutlet weak var logoImageCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageWidthConstraint: NSLayoutConstraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewsAttributes()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.fieldsContainer.alpha = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5) {
                self.logoImageCenterYConstraint.isActive = false
                self.logoImageWidthConstraint.isActive = false
                self.backgroundImageView.setImage(UIImage(named: "Overlay"))
                self.view.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                self.fieldsContainer.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email.isValidEmail, !password.isEmpty else {return}
        
        delegate?.login()
    }
    
    private func setupViewsAttributes() {
        loginButton.layer.cornerRadius = 12
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot?", for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        btn.titleLabel?.font = UIFont(name: "NeuzeitSLTStd-Book", size: 15)
        
        passwordTextField.addRightView(btn)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
