//
//  FeedCacheIntegrationTests.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import XCTest
import Feed

final class FeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    //MARK: - FeedLoader Tests
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueFeedItems().models
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformSecondSave = makeFeedLoader()
        let sutToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueFeedItems().models
        let latestFeed = uniqueFeedItems().models
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(latestFeed, with: feedLoaderToPerformSecondSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    //MARK: - FeedImageDataLoader Tests
    
    func test_loadImageData_deliversDataSavedOnASeparateInstance() {
        
        let imageLoaderToPerformSave = makeFeedImageDataLoader()
        let imageLoaderToPerformLoad = makeFeedImageDataLoader()
        let feedLoader = makeFeedLoader()
        let item = uniqueFeedItem()
        
        let data = anyData()
        save([item], with: feedLoader)
        save(data: data, for: item.url, to: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, load: data, form: item.url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        
        let imageLoaderToPerformFirstSave = makeFeedImageDataLoader()
        let imageLoaderToPerformSecondSave = makeFeedImageDataLoader()
        let imageLoaderToPreformLoad = makeFeedImageDataLoader()
        let feedLoader = makeFeedLoader()
        
        let item = uniqueFeedItem()
        let firstData = Data("first data".utf8)
        let lastData = Data("last data".utf8)
        save([item], with: feedLoader)
        save(data: firstData, for: item.url, to: imageLoaderToPerformFirstSave)
        save(data: lastData, for: item.url, to: imageLoaderToPerformSecondSave)
        
        expect(imageLoaderToPreformLoad, load: lastData, form: item.url)
    }

    //MARK: - Helpers
    
    private func makeFeedLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> LocalFeedLoader {
        
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func makeFeedImageDataLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> LocalFeedImageDataLoader {
        
        let store = try! CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func save(
        _ feed: [FeedImage],
        with sut: LocalFeedLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            
            if case let .failure(error) = result {
                XCTFail("Expected to save feed successfully, got \(error) instead", file: file, line: line)
            }
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(
        data: Data,
        for url: URL,
        to sut: LocalFeedImageDataLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for save completion")
        sut.save(data, for: url) { result in
            
            if case let .failure(error) = result {
                XCTFail("Expected to save feed successfully, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        load expectedData: Data,
        form url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected \(expectedData), got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        
        cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
