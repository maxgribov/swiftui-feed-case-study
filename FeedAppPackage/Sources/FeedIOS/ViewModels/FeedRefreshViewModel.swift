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
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        
        onLoadingStateChange?(true)
        
        feedLoader.load() { [weak self] result in
            
            guard let self else { return }
            
            if let feed = try? result.get() {
                
                self.onFeedLoad?(feed)
            }
            
            self.onLoadingStateChange?(false)
        }
    }
}
