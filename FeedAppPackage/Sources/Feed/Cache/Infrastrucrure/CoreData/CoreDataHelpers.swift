//
//  CoreDataHelpers.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import CoreData

extension NSPersistentContainer {
    
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

extension NSManagedObjectModel {
    
    static func with(name: String, bundle: Bundle) -> NSManagedObjectModel? {
        
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
