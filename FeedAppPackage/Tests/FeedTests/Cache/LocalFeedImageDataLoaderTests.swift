//
//  LocalFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest
import Feed

protocol FeedImageDataStore {
    
    func retrieve(for url: URL)
}

final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        store.retrieve(for: url)
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
        
        XCTAssertEqual(store.receivedMessages, [.loadImage(url)])
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
        
        enum Message: Equatable {
            
            case loadImage(URL)
        }
        
        func retrieve(for url: URL) {
            
            receivedMessages.append(.loadImage(url))
        }
    }
}
