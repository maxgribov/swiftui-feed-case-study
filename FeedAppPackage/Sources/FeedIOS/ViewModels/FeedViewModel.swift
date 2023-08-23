//
//  FeedViewModel.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import Foundation
import Feed

public final class FeedViewModel: ObservableObject {
    
    @Published public private(set) var isRefreshing = false
    @Published public var models: [FeedImageViewModel] = []
    
    private let refreshViewModel: FeedRefreshViewModel

    init(refreshViewModel: FeedRefreshViewModel) {
        
        self.refreshViewModel = refreshViewModel
        refreshViewModel.onLoadingStateChange = { [weak self] isLoading in
            
            //FIXME: do it on the main thread
            // update tests for it first
            self?.isRefreshing = isLoading
        }
    }
    
    public func viewDidLoad() {
        
        pullToRefresh()
    }
    
    public func pullToRefresh() {
        
        refreshViewModel.loadFeed()
    }
    
    public func feedImageViewDidAppear(for viewModel: FeedImageViewModel) {
        
        loadImageData(for: viewModel)
    }
    
    public func feedImageViewDidDisappear(for viewModel: FeedImageViewModel) {

        cancelImageDataLoading(for: viewModel.id)
    }
    
    public func preloadFeedImageData(for viewModel: FeedImageViewModel) {
        
        loadImageData(for: viewModel)
    }
    
    public func cancelPreloadFeedImageData(for viewModel: FeedImageViewModel) {
        
        cancelImageDataLoading(for: viewModel.id)
    }
}

//MARK: - Internal Helpers

extension FeedViewModel {
    
    func loadImageData(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        loadImageData(for: imageViewModel)
    }
}

//MARK: - Private Helpers

private extension FeedViewModel {
    
    func loadImageData(for imageViewModel: FeedImageViewModel) {
        
        imageViewModel.loadImage()
    }
        
    func cancelImageDataLoading(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        imageViewModel.cancelImageLoad()
    }
}
