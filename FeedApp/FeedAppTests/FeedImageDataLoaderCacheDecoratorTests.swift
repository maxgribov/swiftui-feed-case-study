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

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTest {

    func test_init_doesNotStartLoadingOrSave() {
        
        let (_ , loader, cache) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty)
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoader,
        loader: FeedImageDataLoaderSpy,
        cache: FeedImageDataCacheSpy
    ) {
        
        let loader = FeedImageDataLoaderSpy()
        let cache = FeedImageDataCacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(loader: loader, cache: cache)
        
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, loader, cache)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        
        private(set) var messages = [(data: Data, url: URL, completion: (FeedImageDataCache.Result) -> Void)]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            
            messages.append((data, url, completion))
        }
    }
}
