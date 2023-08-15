//
//  FeedViewModelTests.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import XCTest

final class FeedViewModel {
    
    init(loader: FeedViewModelTests.LoaderSpy) {
        
    }
}

final class FeedViewModelTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        
        let loader = LoaderSpy()
        let _ = FeedViewModel(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    //MARK: - Helpers
    
    class LoaderSpy {
        
        private(set) var loadCallCount = 0
    }
}
