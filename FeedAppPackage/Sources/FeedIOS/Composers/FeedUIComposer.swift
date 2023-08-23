//
//  FeedUIComposer.swift
//  
//
//  Created by Max Gribov on 23.08.2023.
//

import Foundation
import Feed

public final class FeedUIComposer<Image> {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) -> FeedViewModel<Image> {
        
        let refreshViewModel = FeedRefreshViewModel(feedLoader: feedLoader)
        let feedViewModel = FeedViewModel<Image>(refreshViewModel: refreshViewModel)
        refreshViewModel.onFeedLoad = adaptFeedToViewModels(forwardingTo: feedViewModel, imageLoader: imageLoader, imageTransformer: imageTransformer)
        
        return feedViewModel
    }
    
    private static func adaptFeedToViewModels(forwardingTo feedViewModel: FeedViewModel<Image>, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) -> ([FeedImage]) ->Void {
        
        return { [weak feedViewModel] images in
            
            guard let feedViewModel else { return }
            
            feedViewModel.models = map(images: images, imageLoader: imageLoader, feedViewModel: feedViewModel, imageTransformer: imageTransformer)
        }
    }
    
    static func map(images: [FeedImage], imageLoader: FeedImageDataLoader, feedViewModel: FeedViewModel<Image>, imageTransformer: @escaping (Data) -> Image?) -> [FeedImageViewModel<Image>] {
        
        images.map { image in
            
            FeedImageViewModel(
                feedImage: image,
                imageLoader: imageLoader,
                imageTransformer: imageTransformer,
                onRetry: { [image, weak feedViewModel] in feedViewModel?.loadImageData(for: image.id) })
        }
    }
}
