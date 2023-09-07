//
//  FeedPresenter.swift
//  
//
//  Created by Max Gribov on 07.09.2023.
//

import Foundation
import Feed

struct FeedLoadingViewModel {
    
    let isLoading: Bool
}

protocol FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    
    let feed: [FeedImage]
}

protocol FeedView {
    
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {

        loadingView?.display(.init(isLoading: true))
        feedLoader.load() { [weak self] result in
    
            if let feed = try? result.get() {
                
                self?.feedView?.display(.init(feed: feed))
            }
            
            self?.loadingView?.display(.init(isLoading: false))
        }
    }
}
