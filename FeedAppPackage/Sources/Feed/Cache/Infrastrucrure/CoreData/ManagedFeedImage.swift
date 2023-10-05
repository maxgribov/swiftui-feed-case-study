//
//  ManagedFeedImage.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    @NSManaged var data: Data?
}

extension ManagedFeedImage {
    
    var local: LocalFeedImage {
        
        .init(id: id, description: imageDescription, location: location, url: url)
    }
    
    static func image(for url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
}
