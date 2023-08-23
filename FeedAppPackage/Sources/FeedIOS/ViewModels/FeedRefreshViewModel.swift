//
//  FeedRefreshViewModel.swift
//  
//
//  Created by Max Gribov on 21.08.2023.
//

import Foundation
import Combine
import Feed

final class FeedRefreshViewModel: ObservableObject {
    
    private(set) var isRefreshing: CurrentValueSubject<Bool, Never>
    
    private let feedLoader: FeedLoader
    
    init(isRefreshing: Bool, feedLoader: FeedLoader) {
        
        self.isRefreshing = .init(isRefreshing)
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    func refresh() {
        
        isRefreshing.send(true)
        
        feedLoader.load() { [weak self] result in
            
            guard let self else { return }
            
            if let feed = try? result.get() {
                
                self.onRefresh?(feed)
            }
            
            self.isRefreshing.send(false)
        }
    }
}
