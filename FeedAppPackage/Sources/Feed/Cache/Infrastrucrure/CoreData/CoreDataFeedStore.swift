//
//  File.swift
//  
//
//  Created by Max Gribov on 07.08.2023.
//

import CoreData

public final class CoreDataFeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        
        context.perform { [context] in
            action(context)
        }
    }
}
