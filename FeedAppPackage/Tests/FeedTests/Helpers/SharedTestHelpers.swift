//
//  File.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation
import Feed

func anyURL() -> URL {
    
    URL(string: "http://some-url.com")!
}

func anyNSError() -> NSError {
    
    NSError(domain: "any error", code: 0)
}

func uniqueFeedItem() -> FeedImage {
    
    FeedImage(id: UUID(), url: anyURL())
}

func uniqueFeedItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
    
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    
    return (items, localItems)
}

func anyData() -> Data {
    
    Data("any data".utf8)
}

