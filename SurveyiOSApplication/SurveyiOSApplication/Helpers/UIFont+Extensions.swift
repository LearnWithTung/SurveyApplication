//
//  UIFont+Extensions.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 11/06/2021.
//

import UIKit

extension UIFont {
    
    static func neuzeitSLTStd(heavy: Bool, ofSize size: CGFloat = 17) -> UIFont {
        return UIFont(name: heavy ? "NeuzeitSLTStd-BookHeavy" : "NeuzeitSLTStd-Book", size: size) ?? .systemFont(ofSize: size)
    }
    
}
