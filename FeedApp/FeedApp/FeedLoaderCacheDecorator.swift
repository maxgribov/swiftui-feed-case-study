//
//  FeedLoaderCacheDecorator.swift
//  FeedApp
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation
import Feed

public final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let loader: FeedLoader
    private let cache: FeedCache
    
    public init(loader: FeedLoader, cache: FeedCache) {
    
        self.loader = loader
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        loader.load { [loader, cache] result in
            
            if let feed = try? result.get() {
                
                cache.saveIgnoringCompletion(feed)
            }
            
            loader.load(completion: completion)
        }
    }
}

extension FeedCache {
    
    func saveIgnoringCompletion(_ items: [FeedImage]) {
        
        save(items) { _ in }
    }
}
