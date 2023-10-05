//
//  CoreDataFeedImageDataStoreTests.swift
//  
//
//  Created by Max Gribov on 05.10.2023.
//

import XCTest
import Feed

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        
        completion(.success(.none))
    }
    
    public func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWithEmpty() {
        
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrieveWith: notFound(), for: anyURL())
    }

    //MARK: - Helpers
    
    func makeSUT() -> FeedImageDataStore {
        
        let baseBundle = Bundle(for: CoreDataFeedStore.self)
        let packageBundleURL = baseBundle.resourceURL!.appending(component: "FeedAppPackage_Feed.bundle")
        let packageBundle = Bundle(url: packageBundleURL)!
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: packageBundle)
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrieveResult {
        return .success(.none)
    }
    
    private func expect(
        _ sut: FeedImageDataStore,
        toCompleteRetrieveWith expectedResult: FeedImageDataStore.RetrieveResult,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for result")
        sut.retrieve(for: url) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
