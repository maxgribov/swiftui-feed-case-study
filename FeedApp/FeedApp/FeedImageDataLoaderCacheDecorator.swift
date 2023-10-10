//
//  FeedImageDataLoaderCacheDecorator.swift
//  FeedApp
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation
import Feed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let loader: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(loader: FeedImageDataLoader, cache: FeedImageDataCache) {
        
        self.loader = loader
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return loader.loadImageData(from: url) { [cache] result in

            if let data = try? result.get() {
                
                cache.saveIgnoringCompletion(data, for: url)
            }
            
            completion(result)
        }
    }
}

extension FeedImageDataCache {
    
    func saveIgnoringCompletion(_ data: Data, for url: URL) {
        
        save(data, for: url) { _ in }
    }
}
