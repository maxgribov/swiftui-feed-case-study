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
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader,
        imageTransformer: @escaping (Data) -> Image?
    ) -> FeedViewModel<Image> {
        
        let feedViewModel = FeedViewModel<Image>(feedLoader: feedLoader)
        feedViewModel.mapImages = feedImagesMapper(
            imageLoader: imageLoader,
            imageTransformer: imageTransformer,
            onRetry: { [weak feedViewModel] feedImage in
                
                return { [weak feedViewModel] in feedViewModel?.loadImageData(for: feedImage.id) }
            })
        
        return feedViewModel
    }
    
    private static func feedImagesMapper(
        imageLoader: FeedImageDataLoader,
        imageTransformer: @escaping (Data) -> Image?,
        onRetry: @escaping (FeedImage) -> () -> Void
    ) -> ([FeedImage]) -> [FeedImageViewModel<Image>] {
        
        return { images in

            return images.map { image in
                
                FeedImageViewModel(
                    feedImage: image,
                    imageLoader: imageLoader,
                    imageTransformer: imageTransformer,
                    onRetry: onRetry(image))
            }
        }
    }
}
