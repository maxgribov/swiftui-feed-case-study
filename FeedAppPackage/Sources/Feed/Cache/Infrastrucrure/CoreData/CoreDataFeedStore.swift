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
        
        perform { context in
            
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
        
        perform { context in
            
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
        
        perform { context in
            
            do {
                
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
                
            } catch {
                
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        
        context.perform { [context] in
            action(context)
        }
    }
}




