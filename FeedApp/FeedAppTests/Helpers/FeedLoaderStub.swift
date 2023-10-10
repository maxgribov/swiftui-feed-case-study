//
//  FeedLoaderStub.swift
//  FeedAppTests
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation
import Feed

class FeedLoaderStub: FeedLoader {
    
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
