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
    
    /// The completion handler con be invoked in any thread.
    /// Cliens are responsable to dispatch to approtpiate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler con be invoked in any thread.
    /// Cliens are responsable to dispatch to approtpiate threads, if needed.
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion)
    
    /// The completion handler con be invoked in any thread.
    /// Cliens are responsable to dispatch to approtpiate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
