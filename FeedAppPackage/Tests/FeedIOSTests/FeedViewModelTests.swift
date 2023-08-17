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
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.viewDidLoad()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.viewDidLoad()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewModel, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = FeedViewModel(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewModel, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewModel, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        guard let viewModel = sut.feedImageViewModel(at: index) else {
            return XCTFail("Expected FeedViewModel, got nil instead", file: file, line: line)
        }
        let expectedIsShowingLocation = image.location != nil
        XCTAssertEqual(viewModel.isShowingLocation, expectedIsShowingLocation, "Expected 'isShowingLocation' to be \(expectedIsShowingLocation), got: \(viewModel.isShowingLocation)", file: file, line: line)
        XCTAssertEqual(viewModel.locationText, image.location, "Expected location text: \(String(describing: image.location)), got: \(String(describing: viewModel.locationText))", file: file, line: line)
        XCTAssertEqual(viewModel.descriptionText, image.description, "Expected description text: \(String(describing: image.description)), got: \(String(describing: viewModel.descriptionText))", file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class LoaderSpy: FeedLoader {
        
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            
            completions[index](.failure(anyError()))
        }
    }
}

private func anyError() -> Error {
    
    NSError(domain: "", code: 0)
}

private extension FeedViewModel {
    
    func simulateUserInitiatedFeedReload() {
        
        pullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        
        isRefreshing
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        
        models.count
    }
    
    func feedImageViewModel(at index: Int) -> FeedImageViewModel? {
        
        guard index >= 0, index < models.count else {
            return nil
        }
        
        return models[index]
    }
}

private extension FeedImageViewModel {
    
    var isShowingLocation: Bool {
        
        location != nil
    }
    
    var locationText: String? {
        
        location
    }
    
    var descriptionText: String? {
        
        description
    }
}
