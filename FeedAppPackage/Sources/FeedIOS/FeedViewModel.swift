//
//  FeedViewModel.swift
//  
//
//  Created by Max Gribov on 14.08.2023.
//

import Foundation
import Feed

public final class FeedViewModel {
    
    @Published public private(set) var isRefreshing: Bool = false
    @Published public private(set) var models: [FeedImageViewModel] = []
    
    private let loader: FeedLoader
    
    public init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    public func viewDidLoad() {
        
        load()
    }
    
    public func pullToRefresh() {
        
        load()
    }
    
    private func load() {
        
        isRefreshing = true
        loader.load() { [weak self] result in
            
            switch result {
            case let .success(feed):
                self?.models = feed.viewModels()
                self?.isRefreshing = false
                
            case .failure:
                break
            }
        }
    }
}

extension Array where Element == FeedImage {
    
    func viewModels() -> [FeedImageViewModel] {
        
        self.map { FeedImageViewModel(id: $0.id, description: $0.description, location: $0.location) }
    }
}
