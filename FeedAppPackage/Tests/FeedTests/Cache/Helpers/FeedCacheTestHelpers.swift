//
//  FeedCacheTestHelpers.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation
import Feed

func uniqueFeedItem() -> FeedImage {
    
    FeedImage(id: UUID(), url: anyURL())
}

func uniqueFeedItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
    
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    
    return (items, localItems)
}

extension Date {
    
    func adding(days: Int) -> Date {
        
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        
        self + seconds
    }
}

