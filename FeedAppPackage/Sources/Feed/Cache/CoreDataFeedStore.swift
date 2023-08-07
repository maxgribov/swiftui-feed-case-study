//
//  File.swift
//  
//
//  Created by Max Gribov on 07.08.2023.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {

    }

    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        completion(.empty)
    }
    
    public func insert(_ items: [Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
