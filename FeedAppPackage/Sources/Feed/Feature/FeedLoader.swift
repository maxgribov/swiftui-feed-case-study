//
//  File.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {

    func load(completion: @escaping (LoadFeedResult) -> Void)
}
