//
//  RemoteFeedLoaderTests.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

class RemoteFeedLoader {
    
    func load() {
        
        HTTPClient.shared.requestedURL = URL(string: "https://google.com")
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}
