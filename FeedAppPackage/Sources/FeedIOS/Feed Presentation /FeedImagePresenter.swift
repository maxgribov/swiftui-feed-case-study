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
    
    typealias Observer<T> = (T) -> Void
    
    private let view: View
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        
        self.view = view
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    func loadImage() {
        
        view.display(FeedImageViewModel(
            isLocationHidden: model.location == nil,
            locationText: model.location,
            descriptionText: model.description,
            image: nil,
            isLoading: true,
            shouldRetry: false))
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] result in
            
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        
        if let image = (try? result.get()).flatMap(imageTransformer) {
            
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
    
    func cancelLoad() {
        
        task?.cancel()
    }
}
