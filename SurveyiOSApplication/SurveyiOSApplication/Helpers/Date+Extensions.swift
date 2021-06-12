//
//  Date+Extensions.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import Foundation

extension Date {
    func dateStringWithFormat(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
