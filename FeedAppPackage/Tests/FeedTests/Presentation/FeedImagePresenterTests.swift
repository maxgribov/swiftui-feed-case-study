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
        
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImage_displaysFeedImageLoadingState() {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        let feedItem = uniqueFeedItem()
        sut.didStartLoadingImage(for: feedItem)
        
        XCTAssertEqual(view.messages, [.displayLoading(feedItem.location, feedItem.description)])
    }
    
    //MARK: - Helpers
    
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
