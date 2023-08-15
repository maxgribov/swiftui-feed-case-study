//
//  FeedViewModelTests.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import XCTest

final class FeedViewModel {
    
    private let loader: FeedViewModelTests.LoaderSpy
    
    init(loader: FeedViewModelTests.LoaderSpy) {
        
        self.loader = loader
    }
    
    func viewDidLoad() {
        
        loader.load()
    }
}

final class FeedViewModelTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        
        let loader = LoaderSpy()
        let _ = FeedViewModel(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        
        let loader = LoaderSpy()
        let sut = FeedViewModel(loader: loader)
        
        sut.viewDidLoad()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    //MARK: - Helpers
    
    class LoaderSpy {
        
        private(set) var loadCallCount = 0
        
        func load() {
            
            loadCallCount += 1
        }
    }
}
