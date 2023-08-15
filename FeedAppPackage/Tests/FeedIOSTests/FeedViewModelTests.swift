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
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.viewDidLoad()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewModel, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = FeedViewModel(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            
            loadCallCount += 1
        }
    }
}
