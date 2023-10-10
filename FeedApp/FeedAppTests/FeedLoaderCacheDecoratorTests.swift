//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import XCTest
import Feed

final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
    
        self.loader = loader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        loader.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTest {

    func test_load_deliversFeedOnFeedLoaderSuccess() {
        
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, result: .success(feed))
    }
    
    func test_load_deliversErrorOnFeedFailure() {
        
        let error = anyNSError()
        let sut = makeSUT(loaderResult: .failure(error))
        
        expect(sut, result: .failure(error))
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        loaderResult: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderCacheDecorator {
        
        let feedLoader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(loader: feedLoader)
        
        trackForMemoryLeaks(feedLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
