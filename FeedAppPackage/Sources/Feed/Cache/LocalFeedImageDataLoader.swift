//
//  File.swift
//  
//
//  Created by Max Gribov on 04.10.2023.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        
        self.store = store
    }
}

extension LocalFeedImageDataLoader {

    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        
        store.insert(data: data, for: url) { [weak self] result in
                
            guard self != nil else { return }
            
            completion(result.mapError{ _ in SaveError.failed })
        }
    }
    
    public enum SaveError: Error {
        
        case failed
    }
}

extension LocalFeedImageDataLoader {
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = Task(completion: completion)
        store.retrieve(for: url) { [weak self] result in
            
            guard self != nil else { return}
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap({ data in data.map { .success($0) } ?? .failure(LoadError.notFound) }))
        }
        
        return task
    }
    
    public enum LoadError: Error {
        
        case failed
        case notFound
    }
    
    final class Task: FeedImageDataLoaderTask {
        
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }

        func complete(with result: FeedImageDataLoader.Result) {
            
            completion?(result)
        }
    }
}
