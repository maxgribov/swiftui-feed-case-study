//
//  FeedCacheIntegrationTests.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import XCTest
import Feed

final class FeedCacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemsOnEmptyCache() {
        
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
                
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        
        let baseBundle = Bundle(for: CoreDataFeedStore.self)
        let packageBundleURL = baseBundle.resourceURL!.appending(component: "FeedAppPackage_Feed.bundle")
        let packageBundle = Bundle(url: packageBundleURL)!
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: packageBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        
        cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
