//
//  FeedPresenterTests.swift
//  
//
//  Created by Max Gribov on 19.09.2023.
//

import XCTest

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
    
    static let noError: FeedErrorViewModel = .init(message: nil)
}

final class FeedPresenter {
    
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
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
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
     
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedLoadingView, FeedErrorView {
        
        enum Message: Equatable {
            
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
