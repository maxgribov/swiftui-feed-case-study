//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import XCTest
import Feed

protocol FeedImageDataCache {
    
    typealias Result = Swift.Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
    
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    init(loader: FeedImageDataLoader, cache: FeedImageDataCache) {
        
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return Task()
    }
    
    private struct Task: FeedImageDataLoaderTask {
        
        func cancel() {
            
        }
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotStartLoadingOrSave() {
        
        let loader = FeedImageLoaderSpy()
        let cache = FeedImageDataCacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(loader: loader, cache: cache)
        
        XCTAssertTrue(loader.messages.isEmpty)
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private class FeedImageLoaderSpy: FeedImageDataLoader {
        
        private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        private(set) var cancelledURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            
            messages.append((url, completion))
            return Task { [weak self] in
                    
                self?.cancelledURLs.append(url)
            }
        }
        
        struct Task: FeedImageDataLoaderTask {
            
            let callback: () -> Void
            
            func cancel() { callback() }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            
            messages[index].completion(.success(data))
        }
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        
        private(set) var messages = [(data: Data, url: URL, completion: (FeedImageDataCache.Result) -> Void)]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            
            messages.append((data, url, completion))
        }
    }
}
