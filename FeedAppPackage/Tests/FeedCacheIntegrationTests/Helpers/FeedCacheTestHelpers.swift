//
//  FeedCacheTestHelpers.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
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
    
    func minusFeedCacheMaxAge() -> Date {
        
        adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        
        self + seconds
    }
}
