//
//  ManagedCache.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
}

extension ManagedCache {
    
    var localFeed: [LocalFeedImage] {
        
        feed
            .compactMap { $0 as? ManagedFeedImage }
            .map{ item in
                LocalFeedImage(id: item.id, description: item.imageDescription, location: item.location, url: item.url)
            }
    }
    
    static func feed(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        
        NSOrderedSet(array: localFeed.map { item in
            
            let managedItem = ManagedFeedImage(context: context)
            managedItem.id = item.id
            managedItem.imageDescription = item.description
            managedItem.location = item.location
            managedItem.url = item.url
            
            return managedItem
        })
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        
        try find(in: context).map(context.delete)
        
        return ManagedCache(context: context)
        
    }
}
