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
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = FeedImageDataLoaderTaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [fallback] result in
            
            if let data = try? result.get() {
                
                completion(.success(data))
                
            } else {
                
                task.wrapped = fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
    
    private final class FeedImageDataLoaderTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            
            wrapped?.cancel()
        }
    }
}

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
    
    func test_load_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
        
        let primaryData = Data("primary".utf8)
        let sut = _makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(anyData()))
        
        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    func test_load_deliversFallbackImageDataOnPrimaryLoaderFailure() {
        
        let fallbackData = Data("fallback".utf8)
        let sut = _makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(fallbackData))
    }
    
    func test_load_deliversErrorOnPrimaryAndFallbackLoadersFail() {
        
        let error = anyNSError()
        let sut = _makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(error))
        
        expect(sut, toCompleteWith: .failure(error))
    }

    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoaderWithFallbackComposite,
        primaryLoader: FeedImageLoaderSpy,
        fallbackLoader: FeedImageLoaderSpy
    ) {
        
        let primaryLoader = FeedImageLoaderSpy()
        let fallbackLoader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func _makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedImageDataLoader {
        
        let primaryLoader = ImageDataLoaderStub(result: primaryResult)
        let fallbackLoader = ImageDataLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class FeedImageLoaderSpy: FeedImageDataLoader {
        
        private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        private(set) var cancelledURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            
            messages.append((url, completion))
            return Task { [weak self] in
                    
                self?.cancelledURLs.append(url)
            }
        }
        
        struct Task: FeedImageDataLoaderTask {
            
            let callback: () -> Void
            
            func cancel() { callback() }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            messages[index].completion(.failure(error))
        }
    }
    
    private class ImageDataLoaderStub: FeedImageDataLoader {
        
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
    
    private func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
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
        
        wait(for: [exp], timeout: 1.0)
    }
}
