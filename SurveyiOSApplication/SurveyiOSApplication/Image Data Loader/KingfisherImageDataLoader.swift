//
//  KingfisherImageDataLoader.swift
//  SurveyiOSApplication
//
//  Created by Tung Vu on 13/06/2021.
//

import Kingfisher

final class KingfisherImageDataLoader: SurveyImageDataLoader {
    private let downloader: ImageDownloader
    init(downloader: ImageDownloader) {
        self.downloader = downloader
    }
    
    private class Task: ImageDataTask {
        var cancelHandler: () -> Void
        
        init(cancelHandler: @escaping () -> Void) {
            self.cancelHandler = cancelHandler
        }
        
        func cancel() {
            cancelHandler()
        }
    }
    
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataTask {
        downloader.downloadImage(with: url, options: nil) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(image):
                completion(.success(image.originalData))
            }
        }
        
        return Task {[weak self] in self?.cancel(url: url)}
    }
    
    private func cancel(url: URL) {
        downloader.cancel(url: url)
    }
    
}
