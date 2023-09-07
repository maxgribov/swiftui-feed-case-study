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
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        
        loadingView.display(.init(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        
        loadingView.display(.init(isLoading: false))
    }
}
