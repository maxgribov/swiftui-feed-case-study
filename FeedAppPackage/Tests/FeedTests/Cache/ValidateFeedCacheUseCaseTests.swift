//
//  ValidateFeedCacheUseCaseTests.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import XCTest
import Feed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validate_deletesCacheOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCahe()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validate_hasNoSideEffectsOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCahe()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validate_doesNotDeletesCacheOnLessThanSevenDaysOldCache() {
        
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let feed = uniqueFeedItems()
        
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.validateCahe()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        
        URL(string: "http://some-url.com")!
    }
    
    private func uniqueFeedItem() -> FeedImage {
        
        FeedImage(id: UUID(), url: anyURL())
    }
    
    private func uniqueFeedItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
        
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        
        return (items, localItems)
    }
}


private extension Date {
    
    func adding(days: Int) -> Date {
        
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        
        self + seconds
    }
}
