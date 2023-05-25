//
//  RemoteFeedLoaderTests.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient()
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
}

class RemoteFeedLoader {
    
}

class HTTPClient {
    
    var requestedURL: URL?
}
