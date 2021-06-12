//
//  UIStoryboard+Extensions.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import UIKit

extension UIStoryboard {
    func instantiate<T>() -> T {
        return instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}
