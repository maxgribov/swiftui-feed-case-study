//
//  FeedImageDataStoreSpy.swift
//  
//
//  Created by Max Gribov on 05.10.2023.
//

import Foundation
import Feed

class FeedImageDataStoreSpy: FeedImageDataStore {
    
    var receivedMessages = [Message]()
    var retrievalCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    
    enum Message: Equatable {
        
        case retrieve(URL)
        case insert(Data, URL)
    }
    
    func retrieve(for url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void){
        
        receivedMessages.append(.retrieve(url))
        retrievalCompletions.append(completion)
    }
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        
        receivedMessages.append(.insert(data, url))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        
        retrievalCompletions[index](.failure(error))
    }
}
