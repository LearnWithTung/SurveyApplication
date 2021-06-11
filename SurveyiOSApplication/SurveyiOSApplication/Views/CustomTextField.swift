//
//  CustomTextField.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

public final class CustomTextField: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBInspectable
    var cornerRadius: CGFloat = 8 {
        didSet {
            layer.cornerRadius = cornerRadius
            containerView.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var placeHolder: String = "" {
        didSet {
            inputTextField.attributedPlaceholder = NSMutableAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.2)])
        }
    }
    
    @IBInspectable
    var fontSize: CGFloat = 14 {
        didSet {
            inputTextField.font = .systemFont(ofSize: fontSize)
        }
    }
    
    @IBInspectable
    var isSecurityField: Bool = false {
        didSet {
            inputTextField.isSecureTextEntry = isSecurityField
        }
    }
    
    @IBInspectable var keyboard: Int = 0{
        didSet {
            inputTextField.keyboardType = UIKeyboardType.init(rawValue: keyboard) ?? .default
        }
    }
    
    public var text: String? {
        get {
            return inputTextField.text ?? ""
        }
        set {
            inputTextField.text = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        customInit()
    }
    
    private func customInit(){
        let contentView = UINib(nibName: "CustomTextField", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func addRightView(_ view: UIView) {
        inputTextField.rightView = view
        inputTextField.rightViewMode = .always
    }
}
