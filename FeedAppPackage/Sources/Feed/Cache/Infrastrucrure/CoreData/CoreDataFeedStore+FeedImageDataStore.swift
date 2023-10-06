//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  
//
//  Created by Max Gribov on 06.10.2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedFeedImage.image(for: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedFeedImage.image(for: url, in: context)?.data
            })
        }
    }
}
