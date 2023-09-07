//
//  FeedPresenter.swift
//  
//
//  Created by Max Gribov on 07.09.2023.
//

import Foundation
import Feed

protocol FeedLoadingView {
    
    func display(isLoading: Bool)
}

protocol FeedView {
    
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {

        loadingView?.display(isLoading: true)
        feedLoader.load() { [weak self] result in
    
            if let feed = try? result.get() {
                
                self?.feedView?.display(feed: feed)
            }
            
            self?.loadingView?.display(isLoading: false)
        }
    }
}
