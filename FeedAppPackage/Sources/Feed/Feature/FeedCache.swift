//
//  File.swift
//  
//
//  Created by Max Gribov on 10.10.2023.
//

import Foundation

public protocol FeedCache {
    
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ items: [FeedImage], completion: @escaping (Result) -> Void)
}
