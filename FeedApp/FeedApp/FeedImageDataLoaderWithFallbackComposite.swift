//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  FeedApp
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation
import Feed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = FeedImageDataLoaderTaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [fallback] result in
            
            if let data = try? result.get() {
                
                completion(.success(data))
                
            } else {
                
                task.wrapped = fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
    
    private final class FeedImageDataLoaderTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            
            wrapped?.cancel()
        }
    }
}
