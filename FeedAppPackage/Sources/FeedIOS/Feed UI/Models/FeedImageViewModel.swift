//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import Foundation
import Feed

final class FeedImageViewModel<Image> {
    
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var isLocationHidden: Bool {
        model.location == nil
    }
    
    var locationText: String? {
        model.location
    }
    
    var descriptionText: String? {
        model.description
    }
    
    var imageURL: URL {
        model.url
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImage() {
        
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] result in
            
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        
        if let image = (try? result.get()).flatMap(imageTransformer) {
            
            onImageLoad?(image)
            
        } else {
            
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelLoad() {
        
        task?.cancel()
    }
}
