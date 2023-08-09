//
//  RemoteFeedItem.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation

 struct RemoteFeedItem: Decodable {
    
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
