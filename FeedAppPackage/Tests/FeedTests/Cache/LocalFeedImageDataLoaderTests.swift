//
//  LocalFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest
import Feed

protocol FeedImageDataStoreTask {
    
    func cancel()
}

protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    
    @discardableResult
    func retrieve(for url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataStoreTask
}

final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = FeedImageDataLoaderTaskWrapper(completion: completion)
        task.wrapped = store.retrieve(for: url) { result in
            
            completion(result.flatMap({ data in
                
                if let data = data {
                    
                    return .success(data)
                    
                } else {
                    
                    return .failure(Error.notFound)
                }
            }))
        }
        
        return task
    }
    
    enum Error: Swift.Error {
        case notFound
    }
    
    class FeedImageDataLoaderTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: FeedImageDataStoreTask?
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            wrapped?.cancel()
            completion = nil
        }

        func complete(with result: FeedImageDataLoader.Result) {
            
            completion?(result)
        }
    }
    
    struct Task: FeedImageDataLoaderTask {
        func cancel() {
        }
    }
}

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
    
    func test_loadImageData_receivesNotFoundErrorOnStoreEmptyData() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, result: failure(.notFound)) {
            
            store.complete(with: nil)
        }
    }
    
    func test_loadImageData_deliversErrorOnStoreError() {
        
        let (sut, store) = makeSUT()
        
        let storeError = NSError(domain: "a store error", code: 0)
        
        expect(sut, result: .failure(storeError)) {
            
            store.complete(with: storeError)
        }
    }
    
    func test_loadImageData_deliversDataOnStoreData() {
        
        let (sut, store) = makeSUT()
        
        let imageData = Data("image data".utf8)
        
        expect(sut, result: .success(imageData)) {
            
            store.complete(with: imageData)
        }
    }
    
    func test_cancelLoadImageData_messageStoreCancelRetrieveImage() {
        
        let (sut, store) = makeSUT()
        
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(url), .cancelRetrieve(url)])
    }
    
//    func test_cancelLoadImageData_deliversNoResult() {
//        
//        let (sut, store) = makeSUT()
//        
//        var receivedResults = [FeedImageDataLoader.Result]()
//        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0) }
//        task.cancel()
//        
//        store.complete(with: nil)
//        store.complete(with: Data("some data".utf8))
//        store.complete(with: anyNSError())
//        
//        XCTAssertTrue(receivedResults.isEmpty)
//    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedImageDataLoader, store: LocalStoreSpy) {
        
        let store = LocalStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (sut, store)
    }
    
    class LocalStoreSpy: FeedImageDataStore {
        
        var completions = [(FeedImageDataStore.Result) -> Void]()
        var receivedMessages = [Message]()
        
        enum Message: Equatable {
            
            case retrieve(URL)
            case cancelRetrieve(URL)
        }
        
        @discardableResult
        func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) -> FeedImageDataStoreTask {
            
            receivedMessages.append(.retrieve(url))
            completions.append(completion)
            
            return Task { [weak self] in
                self?.receivedMessages.append(.cancelRetrieve(url))
            }
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            
            completions[index](.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            completions[index](.failure(error))
        }
        
        struct Task: FeedImageDataStoreTask {
            
            let callback: () -> Void
            
            func cancel() { callback() }
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
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case let (.failure(receivedNSError as NSError), .failure(expectedNSError as NSError)):
                XCTAssertEqual(receivedNSError, expectedNSError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: LocalFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
}
