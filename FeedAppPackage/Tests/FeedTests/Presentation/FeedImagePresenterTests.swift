//
//  FeedImagePresenterTests.swift
//  
//
//  Created by Max Gribov on 21.09.2023.
//

import XCTest
import Feed

protocol FeedImageView {
    
    func display(_ viewModel: FeedImageViewModel)
}

struct FeedImageViewModel {
    
    let locationText: String?
    let descriptionText: String?
    let imageState: ImageState
    
    enum ImageState {
        case loading
    }
}

final class FeedImagePresenter {
    
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        
        self.view = view
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .loading))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSentMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImage_displaysFeedImageLoadingState() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        sut.didStartLoadingImage(for: feedItem)
        
        XCTAssertEqual(view.messages, [.displayLoading(feedItem.location, feedItem.description)])
    }
    
    func test_didFinishLoadingImageWithData_displaysLoadedImage() {
        
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            
            case displayLoading(String?, String?)
        }
        
        func display(_ viewModel: FeedImageViewModel) {
            
            messages.append(.displayLoading(viewModel.locationText, viewModel.descriptionText))
        }
    }
}
