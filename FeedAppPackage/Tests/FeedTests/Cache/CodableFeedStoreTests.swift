//
//  CodableFeedStoreTests.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import XCTest
import Feed

class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] { feed.map(\.local) }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init( _ local: LocalFeedImage) {
            
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
        
        var local: LocalFeedImage {
            
            .init(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            
        } catch {
            
            completion(.failure(error))
        }
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        do {
            
            let encoder = JSONEncoder()
            let cache = Cache(feed: items.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
            
        } catch {
            
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            
            try fileManager.removeItem(at: storeURL)
            completion(nil)
            
        } catch {
            
            completion(error)
        }
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
        
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
  
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueFeedItems().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueFeedItems().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
        let sut = makeSUT()
        
        let firstIsertionError = insert((uniqueFeedItems().local, Date()), to: sut)
        XCTAssertNil(firstIsertionError, "Expected feed to be inserted successfully")
        
        let latestFeed = uniqueFeedItems().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected feed to be inserted successfully")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueFeedItems().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
        let sut = makeSUT()
        insert((uniqueFeedItems().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {

        let noDeletePermissionsURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionsURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    //MARK: - Helpes
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func insert( _ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        
        var insertionError: Error?
        
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func deleteCache(from sut: CodableFeedStore) -> Error? {
        
        var deletionError: Error?
        
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCachedFeed { receivedDeletionError in
            
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func testSpecificStoreURL() -> URL {
        
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
}
