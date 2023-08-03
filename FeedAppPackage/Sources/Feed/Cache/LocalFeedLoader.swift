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
    private let calendar = Calendar(identifier: .gregorian)
    
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
        
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(feed, timestamp) where validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .found:
                completion(.success([]))
                
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validateCahe() {
        
        store.retrieve { [unowned self] result in
            
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }
                
            case let .found(_ , timestamp) where !validate(timestamp):
                store.deleteCachedFeed { _ in }
                
            case .empty, .found:
                break
            }
        }
    }
    
    private var maxCacheAgeInDays: Int { 7 }
    
    private func validate(_ timestamp: Date) -> Bool {
        
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
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
