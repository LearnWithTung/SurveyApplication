//
//  SurveyImageDataLoader.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 12/06/2021.
//

import Foundation

public protocol ImageDataTask {
    func cancel()
}

public protocol SurveyImageDataLoader {
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataTask
}
