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
        loader.load() { [weak self] _ in
            
            self?.isRefreshing = false
        }
    }
}
