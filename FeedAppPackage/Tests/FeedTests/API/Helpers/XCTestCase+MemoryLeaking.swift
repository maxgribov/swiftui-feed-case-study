//
//  XCTestCase+MemoryLeaking.swift
//  
//
//  Created by Max Gribov on 12.06.2023.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks( _ instanse: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        
        addTeardownBlock { [weak instanse] in
             
            XCTAssertNil(instanse, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
