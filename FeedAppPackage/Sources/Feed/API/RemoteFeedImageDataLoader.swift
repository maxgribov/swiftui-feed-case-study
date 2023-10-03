//
//  File.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url) {[weak self] result in
            
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        
        return task
    }
    
    final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: HTTPClientTask?
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            
            self.completion = completion
        }
        
        func cancel() {
            wrapped?.cancel()
            completion = nil
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            
            completion?(result)
        }
    }
    
    public enum Error: Swift.Error {
        
        case connectivity
        case invalidData
    }
}
