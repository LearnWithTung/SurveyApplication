//
//  LoginViewController.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public protocol LoginViewControllerDelegate: AnyObject {
    func login(email: String, password: String, completion: @escaping () -> Void)
}

public class LoginViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var delegate: LoginViewControllerDelegate?
    
    @IBOutlet weak var fieldsContainer: UIStackView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet public private(set) weak var emailTextField: CustomTextField!
    @IBOutlet public private(set) weak var passwordTextField: CustomTextField!
    @IBOutlet public private(set) weak var loginButton: UIButton!
    @IBOutlet weak var logoImageCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) weak var loadingView: LoadingView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewsAttributes()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        appearingAnimation()
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email.isValidEmail, !password.isEmpty else {return}
        
        loadingView.isHidden = false
        loadingView.showIndicator()
        delegate?.login(email: email, password: password) {[weak self] in
            self?.loadingView.isHidden = true
        }
    }
    
    private func appearingAnimation() {
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
    
    private func setupViewsAttributes() {
        fieldsContainer.alpha = 0
        loginButton.layer.cornerRadius = 12
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot?", for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        btn.titleLabel?.font = UIFont.neuzeitSLTStd(heavy: false, ofSize: 15)
        
        passwordTextField.addRightView(btn)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
