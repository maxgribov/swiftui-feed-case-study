//
//  LocalFeedLoader.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            
            guard let self else { return }

            if let cacheDeletionError {
                
                completion(cacheDeletionError)

            } else {
                
                self.cache(items, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        
        store.retrieve { [unowned self] result in
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(feed, timestamp) where validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else { return false }
        
        return currentDate() < maxCacheAge
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] cacheInsertionError in
            
            guard self != nil else { return }
            
            completion(cacheInsertionError)
        }
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        
        map{ .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {

    func toModels() -> [FeedImage] {
        
        map{ .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
