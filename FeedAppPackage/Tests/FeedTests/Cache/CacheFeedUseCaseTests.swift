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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        
        store.deleteCachedFeed { [unowned self] error in
            
            if error == nil {
                
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
        
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        receivedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccesfuly(at index: Int = 0) {
        
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        
        receivedMessages.append(.insert(items, timestamp))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotReuqestCacheInsertionOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completeDeletionSuccesfuly()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    //MARK: - Helpers
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
