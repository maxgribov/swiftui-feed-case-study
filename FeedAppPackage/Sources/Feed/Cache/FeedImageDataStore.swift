//
//  File.swift
//  
//
//  Created by Max Gribov on 04.10.2023.
//

import Foundation

public protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(for url: URL, completion: @escaping (Result) -> Void)
}
