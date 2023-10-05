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
    
    enum Message: Equatable {
        
        case retrieve(URL)
        case insert(Data, URL)
    }
    
    //MARK: - Retrieval
    
    var retrievalCompletions = [(RetrieveResult) -> Void]()
    
    func retrieve(for url: URL, completion: @escaping (RetrieveResult) -> Void){
        
        receivedMessages.append(.retrieve(url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        
        retrievalCompletions[index](.failure(error))
    }
    
    //MARK: - Insertion
    
    var insertionCompletions = [(InsertResult) -> Void]()
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        
        receivedMessages.append(.insert(data, url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfuly(at index: Int = 0) {
        
        insertionCompletions[index](.success(()))
    }
}
