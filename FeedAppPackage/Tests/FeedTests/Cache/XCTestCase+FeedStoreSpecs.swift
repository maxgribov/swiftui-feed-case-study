//
//  XCTestCase+FeedStoreSpecs.swift
//  
//
//  Created by Max Gribov on 04.08.2023.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert( _ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        
        var insertionError: Error?
        
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        
        var deletionError: Error?
        
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCachedFeed { receivedDeletionError in
            
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
}
