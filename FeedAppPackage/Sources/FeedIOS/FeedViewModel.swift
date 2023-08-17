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
            
            self?.models = (try? result.get().viewModels()) ?? []
            self?.isRefreshing = false
        }
    }
}

extension Array where Element == FeedImage {
    
    func viewModels() -> [FeedImageViewModel] {
        
        self.map { FeedImageViewModel(id: $0.id, description: $0.description, location: $0.location) }
    }
}
