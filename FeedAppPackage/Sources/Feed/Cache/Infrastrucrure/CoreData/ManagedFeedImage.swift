//
//  ManagedFeedImage.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

internal extension ManagedFeedImage {
        
    var local: LocalFeedImage {
        
        .init(id: id, description: imageDescription, location: location, url: url)
    }
}
