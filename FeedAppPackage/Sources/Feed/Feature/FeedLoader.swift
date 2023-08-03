//
//  File.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import Foundation

public enum LoadFeedResult {
    
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {

    func load(completion: @escaping (LoadFeedResult) -> Void)
}
