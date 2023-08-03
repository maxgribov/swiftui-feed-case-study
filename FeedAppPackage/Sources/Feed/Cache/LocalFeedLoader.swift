//
//  LocalFeedLoader.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            
            guard let self else { return }

            if let cacheDeletionError {
                
                completion(cacheDeletionError)

            } else {
                
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] cacheInsertionError in
            
            guard self != nil else { return }
            
            completion(cacheInsertionError)
        }
    }
}

private extension Array where Element == FeedItem {
    
    func toLocal() -> [LocalFeedItem] {
        
        map{ .init(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
