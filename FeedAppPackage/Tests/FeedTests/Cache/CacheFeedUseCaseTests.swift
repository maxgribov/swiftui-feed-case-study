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
    
    func deleteCachedFeed() {
        
        deleteCachedFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    //MARK: - Helpers
    
    func uniqueFeedItem() -> FeedItem {
        
        FeedItem(id: UUID(), imageURL: anyURL())
    }
    private func anyURL() -> URL {
        
        URL(string: "http://some-url.com")!
    }
}
