//
//  FeedImagePresenterTests.swift
//  
//
//  Created by Max Gribov on 21.09.2023.
//

import XCTest
import Feed

protocol FeedImageView {
    
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    
    let locationText: String?
    let descriptionText: String?
    let imageState: ImageState
    
    enum ImageState {
        
        case image(Image)
        case loading
        case retry
    }
}

final class FeedImagePresenter<Image, View> where View: FeedImageView, View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .loading))
    }
    
    func didFinishLoadingImage(for model: FeedImage, with imageData: Data) {
        
        if let image = imageTransformer(imageData) {
            
            view.display(FeedImageViewModel(
                locationText: model.location,
                descriptionText: model.description,
                imageState: .image(image)))
            
        } else {
            
            view.display(FeedImageViewModel(
                locationText: model.location,
                descriptionText: model.description,
                imageState: .retry))
        }
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
    
    func test_didFinishLoadingImageWithData_displaysRetryStateForInvalidImageData() {
        
        let (sut, view) = makeSUT()
        
        let feedItem = uniqueFeedItem()
        let invalidImageData = Data("invalid".utf8)
        sut.didFinishLoadingImage(for: feedItem, with: invalidImageData)
        
        XCTAssertEqual(view.messages, [.displayRetry(feedItem.location, feedItem.description)])
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<String, ViewSpy>, view: ViewSpy) {
        
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
        }
        
        func display(_ viewModel: FeedImageViewModel<String>) {
            
            switch viewModel.imageState {
            case .loading:
                messages.append(.displayLoading(viewModel.locationText, viewModel.descriptionText))
                
            case .retry:
                messages.append(.displayRetry(viewModel.locationText, viewModel.descriptionText))
                
            default:
                break
            }
        }
    }
    
    private static func imageTransformer(_ data: Data) -> String? {
        
        return nil
    }
}
