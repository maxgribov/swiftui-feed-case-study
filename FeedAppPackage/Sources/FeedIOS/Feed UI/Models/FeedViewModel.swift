//
//  FeedViewModel.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import Foundation
import Feed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    func loadFeed() {

        isLoading = true
        feedLoader.load() { [weak self] result in
    
            if let feed = try? result.get() {
                
                self?.onFeedLoad?(feed)
            }
            
            self?.isLoading = false
        }
    }
}
