//
//  CacheFeedUseCaseTests.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import XCTest
import Feed

class LocalFeedLoader {
    
    private let store: FeedStore
    
    init(store: FeedStore) {
        
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        
        store.deleteCachedFeed()
    }
}

class FeedStore {
    
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: Error) {
        
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotReuqestCacheInsertionOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    //MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    func uniqueFeedItem() -> FeedItem {
        
        FeedItem(id: UUID(), imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        
        URL(string: "http://some-url.com")!
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0)
    }
}
