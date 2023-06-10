//
//  File.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import Foundation

public struct FeedItem: Equatable {

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

extension FeedItem: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, description, location
        case imageURL = "image"
    }
}
