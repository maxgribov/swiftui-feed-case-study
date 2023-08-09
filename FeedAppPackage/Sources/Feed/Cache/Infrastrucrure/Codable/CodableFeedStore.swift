//
//  CodableFeedStore.swift
//  
//
//  Created by Max Gribov on 04.08.2023.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] { feed.map(\.local) }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init( _ local: LocalFeedImage) {
            
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
        
        var local: LocalFeedImage {
            
            .init(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        queue.async { [storeURL] in
            
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.empty))
            }
            
            do {
                
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                
                completion(.success(.found(feed: cache.localFeed, timestamp: cache.timestamp)))
                
            } catch {
                
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        queue.async(flags: .barrier) { [storeURL] in
            
            do {
                
                let encoder = JSONEncoder()
                let cache = Cache(feed: items.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
                
            } catch {
                
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        queue.async(flags: .barrier) { [storeURL] in
            
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                
                try fileManager.removeItem(at: storeURL)
                completion(nil)
                
            } catch {
                
                completion(error)
            }
        }
    }
}
