//
//  FeedPresenter.swift
//  
//
//  Created by Max Gribov on 19.09.2023.
//

import Foundation

public protocol FeedView {
    
    func display(_ viewModel: FeedViewModel)
}

public struct FeedViewModel {
    
    public let feed: [FeedImage]
}

public protocol FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedLoadingViewModel {
    
    public let isLoading: Bool
}

public protocol FeedErrorView {
    
    func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedErrorViewModel {
    
    public let message: String?
    
    static func noError() -> FeedErrorViewModel {
        
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        
        FeedErrorViewModel(message: message)
    }
}

public final class FeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static var title: String { "Feed" }
    
    public func didStartLoadingFeed() {
        
        loadingView.display(.init(isLoading: true))
        errorView.display(.noError())
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        
        errorView.display(.error(message: "Connection error"))
        loadingView.display(.init(isLoading: false))
    }
}
