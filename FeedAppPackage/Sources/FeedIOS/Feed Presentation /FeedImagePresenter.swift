//
//  FeedImagePresenter.swift
//  
//
//  Created by Max Gribov on 07.09.2023.
//

import Foundation
import Feed

protocol FeedImageView {
    
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View, Image> where View: FeedImageView, View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        
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
    
    func didFinishLoadingImage(for model: FeedImage, with error: Error) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .retry))
    }
    
    func didCancelledLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            locationText: model.location,
            descriptionText: model.description,
            imageState: .retry))
    }
}
