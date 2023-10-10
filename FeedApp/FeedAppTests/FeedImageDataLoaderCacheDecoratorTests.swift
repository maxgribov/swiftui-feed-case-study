//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import XCTest
import Feed

protocol FeedImageDataCache {
    
    typealias Result = Swift.Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let loader: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(loader: FeedImageDataLoader, cache: FeedImageDataCache) {
        
        self.loader = loader
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return loader.loadImageData(from: url) { [cache] result in

            if let data = try? result.get() {
                
                cache.save(data, for: url) { _ in }
            }
            
            completion(result)
        }
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTest {

    func test_init_doesNotStartLoadingOrSave() {
        
        let (_ , loader, cache) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty)
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    func test_load_deliversImageDataOnLoaderSuccess() {
        
        let (sut, loader, _) = makeSUT()
        
        let imageData = Data("image data".utf8)
        expect(sut, toCompleteWith: .success(imageData), on: {
            
            loader.complete(with: imageData)
        })
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        
        let (sut, loader, _) = makeSUT()
        
        let error = anyNSError()
        expect(sut, toCompleteWith: .failure(error), on: {
            
            loader.complete(with: error)
        })
    }
    
    func test_cancelTask_cancelsLoaderTask() {
        
        let (sut, loader, _) = makeSUT()
        
        let url = anyURL()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_load_messagesCacheToSaveImageDataOnLoaderSuccess() {
        
        let (sut, loader, cache) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        let imageData = Data("image data".utf8)
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.saveRequestsURLs, [url])
        XCTAssertEqual(cache.saveRequestsData, [imageData])
    }
    
    func test_load_doesNotMessagesCacheOnLoaderFailure() {
        
        let (sut, loader, cache) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.complete(with: anyNSError())
        
        XCTAssertTrue(cache.saveRequestsData.isEmpty)
        XCTAssertTrue(cache.saveRequestsURLs.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoader,
        loader: FeedImageDataLoaderSpy,
        cache: FeedImageDataCacheSpy
    ) {
        
        let loader = FeedImageDataLoaderSpy()
        let cache = FeedImageDataCacheSpy()
        let sut = FeedImageDataLoaderCacheDecorator(loader: loader, cache: cache)
        
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, loader, cache)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        
        private(set) var messages = [(data: Data, url: URL, completion: (FeedImageDataCache.Result) -> Void)]()
        
        var saveRequestsURLs: [URL] {
            messages.map(\.url)
        }
        
        var saveRequestsData: [Data] {
            messages.map(\.data)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            
            messages.append((data, url, completion))
        }
    }
}
