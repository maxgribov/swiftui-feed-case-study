//
//  File.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import Foundation

public struct FeedItem: Equatable {
    
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
