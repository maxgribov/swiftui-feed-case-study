//
//  FeedImagePresenter.swift
//  
//
//  Created by Max Gribov on 27.09.2023.
//

import Foundation

public protocol FeedImageView {
    
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public struct FeedImageViewModel<Image> {
    
    public let locationText: String?
    public let descriptionText: String?
    public let imageState: ImageState
    
    public enum ImageState {
        
        case image(Image)
        case loading
        case retry
    }
}

public final class FeedImagePresenter<Image, View> where View: FeedImageView, View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .loading))
    }
    
    public func didFinishLoadingImage(for model: FeedImage, with imageData: Data) {
        
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
    
    public func didFinishLoadingImage(for model: FeedImage, with error: Error) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .retry))
    }
    
    public func didCancelledLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .retry))
    }
}
