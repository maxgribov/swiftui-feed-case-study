//
//  File.swift
//  
//
//  Created by Max Gribov on 07.08.2023.
//

import CoreData

//MARK: - FeedStore

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedCache.find(in: context).map {
                    
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ items: [Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        perform { context in
            
            completion(Result {
                
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedCache.feed(from: items, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        perform { context in
            
            completion(Result {
                
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        
        context.perform { [context] in
            action(context)
        }
    }
}

//MARK: - FeedImageDataStore

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        
        perform { context in
            
            completion(Result {
                
                let image = try ManagedFeedImage.image(for: url, in: context)
                image?.data = data
                try context.save()
                
                return ()
            })
        }
    }
    
    public func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        
        perform { context in
            
            completion(Result {
                try ManagedFeedImage.image(for: url, in: context)?.data
            })
        }
    }
}


