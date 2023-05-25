//
//  RemoteFeedLoaderTests.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

class RemoteFeedLoader {
    
    func load() {
        
        HTTPClient.shared.get(from: URL(string: "https://google.com")!)
    }
}

class HTTPClient {
    
    static var shared = HTTPClient()

    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    override func get(from url: URL) {
        
        requestedURL = url
    }
}
