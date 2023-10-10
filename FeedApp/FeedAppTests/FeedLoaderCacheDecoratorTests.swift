//
//  FeedLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import XCTest
import Feed

final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
    
        self.loader = loader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        loader.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnFeedLoaderSuccess() {
        
        let feed = uniqueFeed()
        let feedLoader = LoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(loader: feedLoader)
        
        expect(sut, result: .success(feed))
    }
    
    func test_load_deliversErrorOnFeedFailure() {
        
        let error = anyNSError()
        let feedLoader = LoaderStub(result: .failure(error))
        let sut = FeedLoaderCacheDecorator(loader: feedLoader)
        
        expect(sut, result: .failure(error))
    }
    
    //MARK: - Helpers
    
    private class LoaderStub: FeedLoader {
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private func uniqueFeed() -> [FeedImage] {
        
        [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "https://a-url.com")!)]
    }

    private func expect(
        _ sut: FeedLoader,
        result expectedResult: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
         
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
