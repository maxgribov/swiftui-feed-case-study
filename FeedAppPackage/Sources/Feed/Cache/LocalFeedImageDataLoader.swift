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
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = Task(completion: completion)
        store.retrieve(for: url) { [weak self] result in
            
            guard self != nil else { return}
            
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap({ data in data.map { .success($0) } ?? .failure(Error.notFound) }))
        }
        
        return task
    }
    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        
        store.insert(data: data, for: url, completion: completion)
    }
    
    public enum Error: Swift.Error {
        
        case failed
        case notFound
    }
}

extension LocalFeedImageDataLoader {
    
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
