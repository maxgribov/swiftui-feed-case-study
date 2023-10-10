//
//  FeedImageDataLoaderSpy.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation
import Feed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    private(set) var cancelledURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        messages.append((url, completion))
        return Task { [weak self] in
                
            self?.cancelledURLs.append(url)
        }
    }
    
    struct Task: FeedImageDataLoaderTask {
        
        let callback: () -> Void
        
        func cancel() { callback() }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        
        messages[index].completion(.success(data))
    }
}
