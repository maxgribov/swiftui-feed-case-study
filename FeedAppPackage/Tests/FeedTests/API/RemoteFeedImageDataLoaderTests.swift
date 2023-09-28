//
//  RemoteFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 28.09.2023.
//

import XCTest

final class RemoteFeedImageDataLoader {
    
    init(client: RemoteFeedImageDataLoaderTests.HTTPClientSpy) {
        
    }
    
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotSendAnyRequest() {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertEqual(client.requests.count, 0)
    }
    
    //MARK: - Helpers
    
    class HTTPClientSpy {
        
        var requests = [Any]()
    }
}
