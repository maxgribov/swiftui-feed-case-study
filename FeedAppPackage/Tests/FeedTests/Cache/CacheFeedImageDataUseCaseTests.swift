//
//  CacheFeedImageDataUseCaseTests.swift
//  
//
//  Created by Max Gribov on 05.10.2023.
//

import XCTest
import Feed

final class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveDataForURL_messageStoreInsertData() {
        
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data, url)])
    }
    
    func test_saveDataForURL_failsOnStoreError() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, result: failure(.failed)) {
            
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveDataForURL_successOnSuccessfulStoreInsertion() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, result: .success(())) {
            
            store.completeInsertionSuccessfuly()
        }
    }
    
    func test_saveDataForURL_doesNotDeliverDataAfterSUTInstanceDeallocated() {
        
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = .init(store: store)
        
        var results = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), for: anyURL()) { results.append($0) }
        
        sut = nil
        store.completeInsertionSuccessfuly()
        
        XCTAssertTrue(results.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (sut, store)
    }
    
    private func failure(_ error: LocalFeedImageDataLoader.SaveError) -> LocalFeedImageDataLoader.SaveResult {
        
        .failure(error)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        result expectedResult: LocalFeedImageDataLoader.SaveResult,
        for action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Response")
        sut.save(anyData(), for: anyURL()) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
