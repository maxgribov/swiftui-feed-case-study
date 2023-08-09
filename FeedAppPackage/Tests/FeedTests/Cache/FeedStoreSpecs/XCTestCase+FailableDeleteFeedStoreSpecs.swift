//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  
//
//  Created by Max Gribov on 05.08.2023.
//

import XCTest
import Feed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
