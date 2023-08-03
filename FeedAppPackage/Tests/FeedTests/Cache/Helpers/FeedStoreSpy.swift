//
//  File.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation
import Feed

final class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insetrionsCompletions = [InsetrionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        receivedMessages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccesfuly(at index: Int = 0) {
        
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsetrionCompletion) {
        
        insetrionsCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        
        insetrionsCompletions[index](error)
    }
    
    func completeInsertionSuccessfuly(at index: Int = 0) {
        
        insetrionsCompletions[index](nil)
    }
}
