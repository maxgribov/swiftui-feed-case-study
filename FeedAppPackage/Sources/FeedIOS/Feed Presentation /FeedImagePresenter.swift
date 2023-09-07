//
//  FeedImagePresenter.swift
//  
//
//  Created by Max Gribov on 07.09.2023.
//

import Foundation
import Feed

struct FeedImageViewModel<Image> {
    
    let isLocationHidden: Bool
    let locationText: String?
    let descriptionText: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

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
            isLocationHidden: model.location == nil,
            locationText: model.location,
            descriptionText: model.description,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingImage(for model: FeedImage, with imageData: Data) {
        
        if let image = imageTransformer(imageData) {
            
            view.display(FeedImageViewModel(
                isLocationHidden: model.location == nil,
                locationText: model.location,
                descriptionText: model.description,
                image: image,
                isLoading: false,
                shouldRetry: false))
            
        } else {
            
            view.display(FeedImageViewModel(
                isLocationHidden: model.location == nil,
                locationText: model.location,
                descriptionText: model.description,
                image: nil,
                isLoading: false,
                shouldRetry: true))
        }
    }
    
    func didFinishLoadingImage(for model: FeedImage, with error: Error) {
        
        view.display(FeedImageViewModel(
            isLocationHidden: model.location == nil,
            locationText: model.location,
            descriptionText: model.description,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
    
    func didCancelledLoadingImage(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            isLocationHidden: model.location == nil,
            locationText: model.location,
            descriptionText: model.description,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
