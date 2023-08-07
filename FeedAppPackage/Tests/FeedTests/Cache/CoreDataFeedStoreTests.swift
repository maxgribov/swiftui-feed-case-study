//
//  CoreDataFeedStoreTests.swift
//  
//
//  Created by Max Gribov on 07.08.2023.
//

import XCTest
import Feed

final class CoreDataFeedStore: FeedStore {

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        completion(.empty)
    }
    
    func insert(_ items: [Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    //MARK: - Helpers
    
    func makeSUT() -> FeedStore {
        
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
