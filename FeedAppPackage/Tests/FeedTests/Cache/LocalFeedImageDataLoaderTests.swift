//
//  LocalFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import XCTest

final class LocalFeedImageDataLoader {
    
    init(store: Any) {
        
    }
}


final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        
        let store = LocalStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    //MARK: - Helpers
    
    class LocalStoreSpy {
        
        var receivedMessages = [Any]()
    }
}
