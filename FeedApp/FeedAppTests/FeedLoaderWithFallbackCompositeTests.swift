//
//  FeedLoaderWithFallbackCompositeTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 09.10.2023.
//

import XCTest
import Feed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    
    let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliverPrimaryFeedOnPrimaryLoaderSuccess() {
        
        let primaryFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(uniqueFeed()))
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
         
                
            case let .failure(error):
                XCTFail("Expected \(primaryFeed), got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoader {
        
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func uniqueFeed() -> [FeedImage] {
        
        [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "https://a-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
