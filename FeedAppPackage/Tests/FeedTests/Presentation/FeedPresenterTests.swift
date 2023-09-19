//
//  FeedPresenterTests.swift
//  
//
//  Created by Max Gribov on 19.09.2023.
//

import XCTest

protocol FeedErrorView {
    
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedErrorViewModel {
    
    let message: String?
    
    static let noError: FeedErrorViewModel = .init(message: nil)
}

final class FeedPresenter {
    
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        
        errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
     
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        
        enum Message: Equatable {
            
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
