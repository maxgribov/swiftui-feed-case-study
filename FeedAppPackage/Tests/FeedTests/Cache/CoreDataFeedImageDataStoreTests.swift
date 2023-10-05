//
//  CoreDataFeedImageDataStoreTests.swift
//  
//
//  Created by Max Gribov on 05.10.2023.
//

import XCTest
import Feed



final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWithEmpty() {
        
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrieveWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatchURL() {
        
        let sut = makeSUT()
        let url = URL(string: "http://some-url.com")!
        let notMatchURL = URL(string: "http://not-match-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrieveWith: notFound(), for: notMatchURL)
    }
    
    func test_retrieveImageData_deliversDataWhenStoreDataURLMatchURL() {
        
        let sut = makeSUT()
        
        let url = URL(string: "http://some-url.com")!
        let data = anyData()
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrieveWith: .success(data), for: url)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        
        let sut = makeSUT()
        
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)
        let url = anyURL()
        
        insert(firstData, for: url, into: sut)
        insert(lastData, for: url, into: sut)
        
        expect(sut, toCompleteRetrieveWith: .success(lastData), for: url)
    }
    
    func test_sideEffects_runSerially() {
        
        let sut = makeSUT()
        let url = anyURL()

        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(url: url)], timestamp: Date()) { _ in op1.fulfill() }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(data: anyData(), for: url) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(data: anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }

    //MARK: - Helpers
    
    func makeSUT() -> CoreDataFeedStore {
        
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
        _ sut: CoreDataFeedStore,
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
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                
            case .success:
                sut.insert(data: data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
