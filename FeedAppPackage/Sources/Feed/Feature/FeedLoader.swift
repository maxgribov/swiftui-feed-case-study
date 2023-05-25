//
//  File.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import Foundation

protocol FeedLoader {
    
    func load(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}
