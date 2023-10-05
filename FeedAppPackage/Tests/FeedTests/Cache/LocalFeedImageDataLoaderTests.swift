//
//  LocalFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest
import Feed

final class LocalFeedImageDataLoaderTests: XCTestCase {

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
        
        let store = LocalStoreSpy()
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
    
    private func makeSUT() -> (sut: LocalFeedImageDataLoader, store: LocalStoreSpy) {
        
        let store = LocalStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (sut, store)
    }
    
    class LocalStoreSpy: FeedImageDataStore {
        
        var receivedMessages = [Message]()
        var retrievalCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
        
        enum Message: Equatable {
            
            case retrieve(URL)
            case insert(Data, URL)
        }
        
        func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void){
            
            receivedMessages.append(.retrieve(url))
            retrievalCompletions.append(completion)
        }
        
        func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
            
            receivedMessages.append(.insert(data, url))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            
            retrievalCompletions[index](.success(data))
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            
            retrievalCompletions[index](.failure(error))
        }
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
