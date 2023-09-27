//
//  FeedImagePresenterTests.swift
//  
//
//  Created by Max Gribov on 21.09.2023.
//

import XCTest
import Feed

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
    
    func test_didFinishLoadingImageWithData_displaysRetryStateForInvalidImageData() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        let invalidImageData = invalidImageData
        sut.didFinishLoadingImage(for: feedItem, with: invalidImageData)
        
        XCTAssertEqual(view.messages, [.displayRetry(feedItem.location, feedItem.description)])
    }
    
    func test_didFinishLoadingImageWithData_displayImage() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        let validImageData = validImageData
        sut.didFinishLoadingImage(for: feedItem, with: validImageData)
        
        XCTAssertEqual(view.messages, [.displayImage(feedItem.location, feedItem.description, Self.validImage)])
    }
    
    func test_didFinishLoadingImageWithError_displayRetryButton() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        sut.didFinishLoadingImage(for: feedItem, with: anyNSError())
        
        XCTAssertEqual(view.messages, [.displayRetry(feedItem.location, feedItem.description)])
    }
    
    func test_didCancelledLoadingImage_displayRetryButton() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        sut.didCancelledLoadingImage(for: feedItem)
        
        XCTAssertEqual(view.messages, [.displayRetry(feedItem.location, feedItem.description)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, String>, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: Self.imageTransformer(_:))
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        
        typealias Image = String
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            
            case displayLoading(String?, String?)
            case displayRetry(String?, String?)
            case displayImage(String?, String?, String)
        }
        
        func display(_ viewModel: FeedImageViewModel<String>) {
            
            switch viewModel.imageState {
            case .loading:
                messages.append(.displayLoading(viewModel.locationText, viewModel.descriptionText))
                
            case .retry:
                messages.append(.displayRetry(viewModel.locationText, viewModel.descriptionText))
                
            case let .image(imageValue):
                messages.append(.displayImage(viewModel.locationText, viewModel.descriptionText, imageValue))
            }
        }
    }
    
    private static func imageTransformer(_ data: Data) -> String? {
        
        guard let imageValue = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return imageValue == Self.validImage ? imageValue : nil
    }
    
    private static var validImage: String { "valid" }
    private var validImageData: Data { Data(Self.validImage.utf8) }
    private var invalidImageData: Data { Data("invalid".utf8) }
}
