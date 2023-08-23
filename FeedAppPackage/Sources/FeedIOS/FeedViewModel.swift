//
//  FeedViewModel.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import Foundation
import Feed

public protocol FeedImageDataLoaderTask {
    
    func cancel()
}

public protocol FeedImageDataLoader {
    
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewModel: ObservableObject {
    
    @Published public private(set) var isRefreshing: Bool = false
    @Published public private(set) var models: [FeedImageViewModel] = []
    
    private let imageLoader: FeedImageDataLoader
    private let refreshViewModel: FeedRefreshViewModel
    
    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        
        self.imageLoader = imageLoader
        self.refreshViewModel = FeedRefreshViewModel(isRefreshing: false, feedLoader: feedLoader)
        
        refreshViewModel.isRefreshing
        //FIXME: enable it for production and implement tests with TestScheduler
//            .receive(on: DispatchQueue.main)
            .assign(to: &$isRefreshing)
    }
    
    public func viewDidLoad() {
        
        pullToRefresh()
    }
    
    public func pullToRefresh() {
        
        refreshViewModel.refresh()
        refreshViewModel.onRefresh = { [weak self] images in
            
            guard let self else { return }
            
            self.models = self.map(images: images, imageLoader: imageLoader)
        }
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

private extension FeedViewModel {
    
    func loadImageData(for imageViewModel: FeedImageViewModel) {
        
        imageViewModel.loadImage()
    }
    
    func loadImageData(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        loadImageData(for: imageViewModel)
    }
    
    func cancelImageDataLoading(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        imageViewModel.cancelImageLoad()
    }
    
    func map(images: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageViewModel] {
        
        images.map { image in
            
            FeedImageViewModel(
                feedImage: image,
                imageLoader: imageLoader,
                onRetry: { [image, weak self] in self?.loadImageData(for: image.id) })
        }
    }
}



