//
//  File.swift
//  
//
//  Created by Max Gribov on 07.08.2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        context.perform { [context] in
            
            do {
                
                if let cache = try ManagedCache.find(in: context) {
                    
                    completion(.found(
                        feed: cache.localFeed,
                        timestamp: cache.timestamp))
                    
                } else {
                    
                    completion(.empty)
                }

            } catch {
                
                completion(.failure(error))
            }            
        }
    }
    
    public func insert(_ items: [Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        context.perform { [context] in
            
            do {
                
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedCache.feed(from: items, in: context)
                
                try context.save()
                completion(nil)
                
            } catch {
                
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        context.perform { [context] in
            
            do {
                
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
                
            } catch {
                
                completion(error)
            }
        }
    }
}

private extension NSPersistentContainer {
    
    enum LoadingError: Error {
        case modelNotFound
        case failedLoadingPersistenStore(Error)
    }
    
    static func load(modelName: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: modelName, bundle: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadStoresError: Error?
        container.loadPersistentStores { loadStoresError = $1 }
        try loadStoresError.map{ throw LoadingError.failedLoadingPersistenStore($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    
    static func with(name: String, bundle: Bundle) -> NSManagedObjectModel? {
        
        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            return nil
        }
        
        return model
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
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

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
        
    var local: LocalFeedImage {
        
        .init(id: id, description: imageDescription, location: location, url: url)
    }
}
