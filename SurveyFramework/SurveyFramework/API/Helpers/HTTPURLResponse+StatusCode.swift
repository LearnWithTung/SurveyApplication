//
//  HTTPURLResponse+StatusCode.swift
//  SurveyFramework
//
//  Created by Tung Vu on 11/06/2021.
//

import Foundation

extension HTTPURLResponse {
    private var ok_status: Int {
        return 200
    }
    
    var isOK: Bool {
        return statusCode == ok_status
    }
}
