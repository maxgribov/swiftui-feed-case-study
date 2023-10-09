//
//  FeedLoaderWithFallbackComposite.swift
//  FeedApp
//
//  Created by Max Gribov on 09.10.2023.
//

import Foundation
import Feed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        primary.load { [fallback] result in
            
            if let feed = try? result.get() {
                
                completion(.success(feed))
                
            } else {
                
                fallback.load(completion: completion)
            }
        }
    }
}
