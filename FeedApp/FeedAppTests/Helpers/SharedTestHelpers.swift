//
//  SharedTestHelpers.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import Foundation
import Feed

func anyURL() -> URL {
    
    URL(string: "http://some-url.com")!
}

func anyNSError() -> NSError {
    
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    
    [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "https://a-url.com")!)]
}

