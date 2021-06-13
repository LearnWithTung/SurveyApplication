//
//  UILabel+Animation.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import UIKit

extension UILabel{
    func setText(_ text: String, animated: Bool = true) {
        let duration = animated ? 0.3 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.text = text
        }, completion: nil)
    }
}

