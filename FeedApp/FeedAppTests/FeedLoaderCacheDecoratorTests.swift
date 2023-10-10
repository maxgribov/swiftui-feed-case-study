//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import XCTest
import Feed
import FeedApp

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
    
    func test_load_messagesCacheToSaveItemsOnLoaderSuccess() {
        
        let feed = uniqueFeed()
        let cache = FeedCacheSpy()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotMessageCacheOnFeedLoaderFailure() {
        
        let cache = FeedCacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        loaderResult: FeedLoader.Result,
        cache: FeedCacheSpy = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderCacheDecorator {
        
        let feedLoader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(loader: feedLoader, cache: cache)
        
        trackForMemoryLeaks(feedLoader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class FeedCacheSpy: FeedCache {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            
            case save([FeedImage])
        }
        
        func save(_ items: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
         
            messages.append(.save(items))
        }
    }
}
