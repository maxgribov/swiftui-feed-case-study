//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 09.10.2023.
//

import XCTest
import Feed
import FeedApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotAttemptToLoadPrimaryOrFallbackData() {
        
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty)
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }
    
    func test_load_loadsFromPrimaryLoaderFirst() {
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url])
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }
    
    func test_load_loadsFromFallbackLoaderOnPrimaryFailure() {
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url])
        XCTAssertEqual(fallbackLoader.loadedURLs, [url])
    }
    
    func test_cancelTask_cancelsPrimaryLoaderTask() {
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url])
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty)
    }
    
    func test_cancelTask_cancelsFallbackLoaderTaskOnPrimaryLoaderFailure() {
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty)
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url])
    }
    
    func test_load_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
        
        let primaryData = Data("primary".utf8)
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success(primaryData), on: {
            
            primaryLoader.complete(with: primaryData)
        })
    }
    
    func test_load_deliversFallbackImageDataOnPrimaryLoaderFailure() {
        
        let fallbackData = Data("fallback".utf8)
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(fallbackData), on: {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        })
    }
    
    func test_load_deliversErrorOnPrimaryAndFallbackLoadersFail() {
        
        let error = anyNSError()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(error), on: {
            
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: error)
        })
    }

    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoaderWithFallbackComposite,
        primaryLoader: FeedImageDataLoaderSpy,
        fallbackLoader: FeedImageDataLoaderSpy
    ) {
        
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }

    private func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        on action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                      
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
