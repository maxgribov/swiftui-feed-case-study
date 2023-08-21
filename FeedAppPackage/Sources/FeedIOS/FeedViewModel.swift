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

public final class FeedViewModel {
    
    @Published public private(set) var isRefreshing: Bool = false
    @Published public private(set) var models: [FeedImageViewModel] = []
    
    private let feedLoader: FeedLoader
    private let imageLoader: FeedImageDataLoader
    private var tasks = [FeedImageViewModel.ID: FeedImageDataLoaderTask]()
    
    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public func viewDidLoad() {
        
        load()
    }
    
    public func pullToRefresh() {
        
        load()
    }
    
    public func feedImageViewDidAppear(for viewModel: FeedImageViewModel) {
        
        loadImageData(for: viewModel)
    }
    
    public func feedImageViewDidDisappear(for viewModel: FeedImageViewModel) {

        tasks[viewModel.id]?.cancel()
        tasks[viewModel.id] = nil
    }
    
    public func preloadFeedImageData(for viewModel: FeedImageViewModel) {
        
        loadImageData(for: viewModel)
    }
    
    private func load() {
        
        isRefreshing = true
        feedLoader.load() { [weak self] result in
            
            guard let self else { return }
            
            if let feed = try? result.get() {
                
                self.models = self.map(images: feed)
            }
            
            self.isRefreshing = false
        }
    }
    
    private func loadImageData(for imageViewModel: FeedImageViewModel) {
        
        guard let url = imageViewModel.imageData.url else {
            return
        }
        
        tasks[imageViewModel.id] = imageLoader.loadImageData(from: url) {[weak imageViewModel] result in
            
            switch result {
            case let .success(data):
                imageViewModel?.updateLoaded(url: url, imageData: data)
                
            case .failure:
                imageViewModel?.updateLoaded(url: url, imageData: nil)
            }
        }
    }
    
    private func loadImageData(for imageViewModelID: UUID) {
        
        guard let imageViewModel = models.first(where: { $0.id == imageViewModelID }) else {
            return
        }
        
        loadImageData(for: imageViewModel)
    }
    
    private func map(images: [FeedImage]) -> [FeedImageViewModel] {
        
        images.map { image in
            
            FeedImageViewModel(
                id: image.id,
                description: image.description,
                location: image.location,
                imageData: .load(image.url),
                onRetry: { [image, weak self] in self?.loadImageData(for: image.id) })
        }
    }
}



