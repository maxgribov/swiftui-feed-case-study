//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest
import Feed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageData_messageStoreLoadImage() {
        
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(url)])
    }
    
    func test_loadImageData_messageStoreLoadImageTwice() {
        
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) {_ in }
        _ = sut.loadImageData(from: url) {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(url), .retrieve(url)])
    }
    
    func test_loadImageData_deliversErrorOnStoreError() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, result: failure(.failed)) {
            
            store.completeRetrieval(with: anyNSError())
        }
    }
    
    func test_loadImageData_deliversNotFoundErrorOnStoreEmptyData() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, result: failure(.notFound)) {
            
            store.completeRetrieval(with: nil)
        }
    }
    
    func test_loadImageData_deliversDataOnStoreData() {
        
        let (sut, store) = makeSUT()
        
        let imageData = Data("image data".utf8)
        expect(sut, result: .success(imageData)) {
            
            store.completeRetrieval(with: imageData)
        }
    }
    
    func test_loadImageData_deliversNoAnyResultOnCancel() {
        
        let (sut, store) = makeSUT()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0) }
        task.cancel()
        
        store.completeRetrieval(with: nil)
        store.completeRetrieval(with: Data("some data".utf8))
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { receivedResults.append($0) }
        sut = nil
        
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_saveDataForURL_messageStoreInsertData() {
        
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data, url)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        result expectedResult: FeedImageDataLoader.Result,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Response")
        _ = sut.loadImageData(from: anyURL(), completion: { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: LocalFeedImageDataLoader.LoadError) -> FeedImageDataLoader.Result {
        .failure(error)
    }
}
