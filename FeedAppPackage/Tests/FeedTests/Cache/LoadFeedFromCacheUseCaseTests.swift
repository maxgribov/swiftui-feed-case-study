//
//  LoadFeedFromCacheUseCaseTests.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import XCTest
import Feed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.load { result in
            
            switch result {
            case let .failure(error):
                receivedError = error
                
            default:
                XCTFail("Expected error, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {

        let (sut, store) = makeSUT()

        let exp = expectation(description: "Wait for completion")
        var receivedResult: [FeedImage]?
        sut.load { result in

            switch result {
            case let .success(images):
                receivedResult = images
                
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedResult, [])
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
}
