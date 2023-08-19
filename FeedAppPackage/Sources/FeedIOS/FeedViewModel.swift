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
        
        guard case let .load(url) = viewModel.imageData else {
            return
        }
        
        tasks[viewModel.id] = imageLoader.loadImageData(from: url) {[weak viewModel] result in
            
            switch result {
            case let .success(data):
                viewModel?.updateLoaded(imageData: data)
                
            case .failure:
                viewModel?.updateLoaded(imageData: nil)
            }
        }
    }
    
    public func feedImageViewDidDisappear(for viewModel: FeedImageViewModel) {

        tasks[viewModel.id]?.cancel()
        tasks[viewModel.id] = nil
    }
    
    private func load() {
        
        isRefreshing = true
        feedLoader.load() { [weak self] result in
            
            if let feed = try? result.get() {
                
                self?.models = feed.viewModels()
            }
            
            self?.isRefreshing = false
        }
    }
}

extension Array where Element == FeedImage {
    
    func viewModels() -> [FeedImageViewModel] {
        
        self.map { FeedImageViewModel(id: $0.id, description: $0.description, location: $0.location, imageData: .load($0.url)) }
    }
}
