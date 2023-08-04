//
//  CodableFeedStoreTests.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import XCTest
import Feed

class CodableFeedStore {
    
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
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsetrionCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(feed: items.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
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
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            
            sut.retrieve { secondResult in
                
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected empty each time, but got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let sut = makeSUT()
        let feed = uniqueFeedItems().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            
            XCTAssertNil(insertionError, "No error expected")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueFeedItems().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            
            XCTAssertNil(insertionError, "No error expected")
            
            sut.retrieve { firstResult in
                
                sut.retrieve { secondResult in
                    
                    switch (firstResult, secondResult) {
                    case let (.found(firstFoundFeed, firstFoundTimestamp), .found(secondFoundFeed, secondFoundTimestamp)):
                        XCTAssertEqual(firstFoundFeed, feed)
                        XCTAssertEqual(firstFoundTimestamp, timestamp)
                        
                        XCTAssertEqual(secondFoundFeed, feed)
                        XCTAssertEqual(secondFoundTimestamp, timestamp)
                        
                    default:
                        XCTFail("Expected found result with feed: \(feed), timestamp: \(timestamp), but got \(firstResult) and \(secondResult) instead")
                    }
                    
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpes
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
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
    
    private func testSpecificStoreURL() -> URL {
        
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
