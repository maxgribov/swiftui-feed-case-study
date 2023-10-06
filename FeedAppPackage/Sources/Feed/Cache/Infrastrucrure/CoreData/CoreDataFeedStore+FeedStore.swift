//
//  CoreDataFeedStore+FeedStore.swift
//
//
//  Created by Max Gribov on 06.10.2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedCache.find(in: context).map {
                    
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ items: [Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        perform { context in
            
            completion(Result {
                
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedCache.feed(from: items, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}
