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
        let primaryLoader = FeedLoaderStub(result: .success(primaryFeed))
        let fallbackLoader = FeedLoaderStub(result: .success(uniqueFeed()))
        
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
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
    
    private func uniqueFeed() -> [FeedImage] {
        
        [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "https://a-url.com")!)]
    }
    
    private class FeedLoaderStub: FeedLoader {
        
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
