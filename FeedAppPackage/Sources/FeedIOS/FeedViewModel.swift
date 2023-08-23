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
    @Published public var models: [FeedImageViewModel] = []
    
    private let refreshViewModel: FeedRefreshViewModel
    
    init(refreshViewModel: FeedRefreshViewModel) {
        
        self.refreshViewModel = refreshViewModel

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
    
    func loadImageData(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        loadImageData(for: imageViewModel)
    }
}

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



