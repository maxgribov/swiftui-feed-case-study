//
//  LocalFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest
import Feed

protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(for url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        store.retrieve(for: url) { result in
            
            switch result {
            case let .success(data):
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.notFound))
                }
                
            default:
                break
            }
        }
        return Task()
    }
    
    enum Error: Swift.Error {
        case notFound
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
        
        let exp = expectation(description: "Response")
        _ = sut.loadImageData(from: anyURL(), completion: { result in
            switch result {
            case let .failure(loaderError as LocalFeedImageDataLoader.Error):
                XCTAssertEqual(loaderError, .notFound)
                
            default:
                XCTFail("Expected error, got \(result) instead")
            }
            
            exp.fulfill()
        })
        
        store.complete(with: nil)
        
        wait(for: [exp], timeout: 1.0)
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
        
        var completions = [(FeedImageDataStore.Result) -> Void]()
        var receivedMessages = [Message]()
        
        enum Message: Equatable {
            
            case retrieve(URL)
        }
        
        func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            
            receivedMessages.append(.retrieve(url))
            completions.append(completion)
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            
            completions[index](.success(data))
        }
    }
}
