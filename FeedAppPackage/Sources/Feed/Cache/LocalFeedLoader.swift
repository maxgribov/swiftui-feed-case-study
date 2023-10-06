//
//  LocalFeedLoader.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation

public final class LocalFeedLoader {
        
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        
        store.deleteCachedFeed { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.cache(items, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in completion(.success(()))}
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                store.deleteCachedFeed { _ in completion(.success(()))}
                
            case .success:
                completion(.success(()))
            }
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
