//
//  FeedViewModelTests.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import XCTest
import Feed

final class FeedViewModel {
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    func viewDidLoad() {
        
        loader.load() { _ in }
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
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            
            loadCallCount += 1
        }
    }
}
