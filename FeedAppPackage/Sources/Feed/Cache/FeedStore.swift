//
//  FeedStore.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation

public enum RetrieveCachedFeedResult {
    
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsetrionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
