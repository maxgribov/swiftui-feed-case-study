//
//  FeedStore.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation


public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InseteionResult = Result<Void, Error>
    typealias InsetrionCompletion = (InseteionResult) -> Void
    
    typealias RetrieveResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrieveResult) -> Void
    
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
