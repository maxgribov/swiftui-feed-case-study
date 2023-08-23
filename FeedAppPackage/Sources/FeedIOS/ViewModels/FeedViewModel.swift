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
    
    public let refreshViewModel: FeedRefreshViewModel
    @Published public var models: [FeedImageViewModel] = []

    init(refreshViewModel: FeedRefreshViewModel) {
        
        self.refreshViewModel = refreshViewModel
    }
    
    public func viewDidLoad() {
        
        pullToRefresh()
    }
    
    public func pullToRefresh() {
        
        refreshViewModel.refresh()
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
