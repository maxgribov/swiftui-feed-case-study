//
//  FeedViewModel.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import Foundation
import Feed

public final class FeedViewModel<Image>: ObservableObject {
        
    @Published public private(set) var isRefreshing = false
    @Published public var models: [FeedImageViewModel<Image>] = []
    
    var mapImages: (([FeedImage]) -> [FeedImageViewModel<Image>])?
    
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }
    
    public func viewDidLoad() {
        
        loadFeed()
    }
    
    public func pullToRefresh() {
        
        loadFeed()
    }
    
    public func feedImageViewDidAppear(for imageViewModelID: UUID) {
        
        loadImageData(for: imageViewModelID)
    }
    
    public func feedImageViewDidDisappear(for imageViewModelID: UUID) {

        cancelImageDataLoading(for: imageViewModelID)
    }
    
    public func preloadFeedImageData(for imageViewModelID: UUID) {
        
        loadImageData(for: imageViewModelID)
    }
    
    public func cancelPreloadFeedImageData(for imageViewModelID: UUID) {
        
        cancelImageDataLoading(for: imageViewModelID)
    }
}

//MARK: - Internal Helpers

extension FeedViewModel {
    
    func loadFeed() {
        
        isRefreshing = true
        
        feedLoader.load() { [weak self] result in
            
            guard let self else { return }
            
            if let feed = try? result.get(),
               let models = self.mapImages?(feed) {
                
                self.models = models
            }
            
            //FIXME: do it on the main thread
            // update tests for it first
            self.isRefreshing = false
        }
    }
    
    func loadImageData(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        imageViewModel.loadImage()
    }
}

//MARK: - Private Helpers

private extension FeedViewModel {

    func cancelImageDataLoading(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        imageViewModel.cancelImageLoad()
    }
}
