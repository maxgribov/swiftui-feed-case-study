//
//  FeedViewModelTests.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import XCTest
import Feed

final class FeedViewModel {
    
    @Published var isRefreshing: Bool = false
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    func viewDidLoad() {
        
        isRefreshing = true
        load()
    }
    
    func pullToRefresh() {
        
        isRefreshing = true
        load()
    }
    
    func load() {
        
        loader.load() { [weak self] _ in
            
            self?.isRefreshing = false
        }
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
    
    func test_userInitiatedFeedReload_loadsFeed() {
        
        let (sut, loader) = makeSUT()
        sut.viewDidLoad()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        
        let (sut, _) = makeSUT()
        
        sut.viewDidLoad()
        
        XCTAssertEqual(sut.isRefreshing, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        
        let (sut, loader) = makeSUT()
        
        sut.viewDidLoad()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isRefreshing, false)
    }
    
    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        
        let (sut, _) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(sut.isRefreshing, true)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isRefreshing, false)
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
        
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            
            completions[0](.success([]))
        }
    }
}

private extension FeedViewModel {
    
    func simulateUserInitiatedFeedReload() {
        
        pullToRefresh()
    }
}
