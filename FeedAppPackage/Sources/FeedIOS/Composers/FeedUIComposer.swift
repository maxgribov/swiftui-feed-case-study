//
//  FeedUIComposer.swift
//  
//
//  Created by Max Gribov on 23.08.2023.
//

import Foundation
import CoreGraphics
import Feed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewModel<CGImage> {
        
        let refreshViewModel = FeedRefreshViewModel(feedLoader: feedLoader)
        let feedViewModel = FeedViewModel<CGImage>(refreshViewModel: refreshViewModel)
        refreshViewModel.onFeedLoad = adaptFeedToViewModels(forwardingTo: feedViewModel, imageLoader: imageLoader)
        
        return feedViewModel
    }
    
    private static func adaptFeedToViewModels(forwardingTo feedViewModel: FeedViewModel<CGImage>, imageLoader: FeedImageDataLoader) -> ([FeedImage]) ->Void {
        
        return { [weak feedViewModel] images in
            
            guard let feedViewModel else { return }
            
            feedViewModel.models = map(images: images, imageLoader: imageLoader, feedViewModel: feedViewModel)
        }
    }
    
    static func map(images: [FeedImage], imageLoader: FeedImageDataLoader, feedViewModel: FeedViewModel<CGImage>) -> [FeedImageViewModel<CGImage>] {
        
        images.map { image in
            
            FeedImageViewModel(
                feedImage: image,
                imageLoader: imageLoader,
                imageTransformer: CGImage.image(fromPng:),
                onRetry: { [image, weak feedViewModel] in feedViewModel?.loadImageData(for: image.id) })
        }
    }
}
