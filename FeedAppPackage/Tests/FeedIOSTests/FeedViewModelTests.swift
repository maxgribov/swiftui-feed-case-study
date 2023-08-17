//
//  FeedViewModelTests.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import XCTest
import Feed
import FeedIOS

final class FeedViewModelTests: XCTestCase {

    func test_loadFeedActions_requestsFeedFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.viewDidLoad()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates to load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.viewDidLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading is completed")
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
        
        func completeFeedLoading(at index: Int = 0) {
            
            completions[index](.success([]))
        }
    }
}

private extension FeedViewModel {
    
    func simulateUserInitiatedFeedReload() {
        
        pullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        
        isRefreshing
    }
}
