//
//  FeedUIComposer.swift
//  
//
//  Created by Max Gribov on 23.08.2023.
//

import Foundation
import Feed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewModel {
        
        let refreshViewModel = FeedRefreshViewModel(isRefreshing: false, feedLoader: feedLoader)
        let feedViewModel = FeedViewModel(refreshViewModel: refreshViewModel)
        refreshViewModel.onRefresh = adaptFeedToViewModels(forwardingTo: feedViewModel, imageLoader: imageLoader)
        
        return feedViewModel
    }
    
    private static func adaptFeedToViewModels(forwardingTo feedViewModel: FeedViewModel, imageLoader: FeedImageDataLoader) -> ([FeedImage]) ->Void {
        
        return { [weak feedViewModel] images in
            
            guard let feedViewModel else { return }
            
            feedViewModel.models = map(images: images, imageLoader: imageLoader, feedViewModel: feedViewModel)
        }
    }
    
    static func map(images: [FeedImage], imageLoader: FeedImageDataLoader, feedViewModel: FeedViewModel) -> [FeedImageViewModel] {
        
        images.map { image in
            
            FeedImageViewModel(
                feedImage: image,
                imageLoader: imageLoader,
                onRetry: { [image, weak feedViewModel] in feedViewModel?.loadImageData(for: image.id) })
        }
    }
}
