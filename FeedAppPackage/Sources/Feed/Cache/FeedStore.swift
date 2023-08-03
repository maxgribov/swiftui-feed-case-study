//
//  FeedStore.swift
//  
//
//  Created by Max Gribov on 02.08.2023.
//

import Foundation

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsetrionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsetrionCompletion)
}

public struct LocalFeedItem: Equatable {

    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
