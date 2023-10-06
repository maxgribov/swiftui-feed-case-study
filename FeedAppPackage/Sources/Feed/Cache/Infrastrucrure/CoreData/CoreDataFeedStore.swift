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
    
    public init(storeURL: URL) throws {
        
        let baseBundle = Bundle(for: CoreDataFeedStore.self)
        let packageBundleURL = baseBundle.resourceURL!.appending(component: "FeedAppPackage_Feed.bundle")
        let packageBundle = Bundle(url: packageBundleURL)!
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: packageBundle)
        context = container.newBackgroundContext()
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        
        context.perform { [context] in
            action(context)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        
        context.performAndWait {
            
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}
