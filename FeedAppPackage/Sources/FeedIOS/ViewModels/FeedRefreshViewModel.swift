//
//  FeedRefreshViewModel.swift
//  
//
//  Created by Max Gribov on 21.08.2023.
//

import Foundation
import Combine
import Feed

public final class FeedRefreshViewModel: ObservableObject {
    
    @Published public private(set) var isRefreshing: Bool
    
    private let feedLoader: FeedLoader
    
    init(isRefreshing: Bool, feedLoader: FeedLoader) {
        
        self.isRefreshing = isRefreshing
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    func refresh() {
        
        isRefreshing = true
        
        feedLoader.load() { [weak self] result in
            
            guard let self else { return }
            
            if let feed = try? result.get() {
                
                self.onRefresh?(feed)
            }
            
            //FIXME: do it on the main thread
            // update tests for it too
            self.isRefreshing = false
        }
    }
}
