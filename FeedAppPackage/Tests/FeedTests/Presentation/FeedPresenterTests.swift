//
//  FeedPresenterTests.swift
//  
//
//  Created by Max Gribov on 19.09.2023.
//

import XCTest
import Feed

protocol FeedView {
    
    func display(_ viewModel: FeedViewModel)
}

struct FeedViewModel {
    
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    
    let isLoading: Bool
}

protocol FeedErrorView {
    
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    
    let message: String?
    
    static func noError() -> FeedErrorViewModel {
        
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        
        FeedErrorViewModel(message: message)
    }
}

final class FeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        
        loadingView.display(.init(isLoading: true))
        errorView.display(.noError())
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        
        errorView.display(.error(message: "Connection error"))
        loadingView.display(.init(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
                                       .display(isLoading: true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        
        let (sut, view) = makeSUT()
        let feed = uniqueFeedItems().models
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(isLoading: false),
                                       .display(feed: feed)])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: "Connection error"),
                                       .display(isLoading: false)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
     
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedView, FeedLoadingView, FeedErrorView {
        
        enum Message: Hashable {
            
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
