//
//  File.swift
//  
//
//  Created by Max Gribov on 04.10.2023.
//

import Foundation

public protocol FeedImageDataStore {
    
    typealias RetrieveResult = Swift.Result<Data?, Error>
    typealias InsertResult = Swift.Result<Void, Error>
    
    func retrieve(for url: URL, completion: @escaping (RetrieveResult) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)
}