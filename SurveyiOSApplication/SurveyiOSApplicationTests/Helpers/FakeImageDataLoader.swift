//
//  FakeImageDataLoader.swift
//  SurveyiOSApplicationTests
//
//  Created by Tung Vu on 13/06/2021.
//

import Foundation
import SurveyiOSApplication

struct Task: ImageDataTask {
    func cancel() {}
}

class FakeImageDataLoader: SurveyImageDataLoader {
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataTask {
        Task()
    }
}
