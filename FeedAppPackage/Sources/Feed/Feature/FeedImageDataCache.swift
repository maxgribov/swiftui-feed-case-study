//
//  FeedImageDataCache.swift
//  
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation

public protocol FeedImageDataCache {
    
    typealias Result = Swift.Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
