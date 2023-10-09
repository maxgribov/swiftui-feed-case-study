//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 09.10.2023.
//

import XCTest
import Feed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private let primary: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
        self.primary = primary
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        primary.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
        
        let primaryData = Data("primary".utf8)
        let primaryLoader = ImageDataLoaderStub(result: .success(primaryData))
        let fallbackLoader = ImageDataLoaderStub(result: .success(Data("fallback".utf8)))
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, primaryData)
                
            default:
                XCTFail("Expected \(primaryData), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    //MARK: - Helpers
    
    class ImageDataLoaderStub: FeedImageDataLoader {
        
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            
            completion(result)
            return Task()
        }
        
        private struct Task: FeedImageDataLoaderTask {
            
            func cancel() {}
        }
    }
    
    private func anyData() -> Data {
        
        Data("any data".utf8)
    }
    
    private func anyURL() -> URL {
        
        URL(string: "https://any-url.com")!
    }
}
