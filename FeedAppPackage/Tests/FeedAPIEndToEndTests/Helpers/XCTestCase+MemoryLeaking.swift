//
//  File.swift
//  
//
//  Created by Max Gribov on 19.06.2023.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks( _ instanse: AnyObject, file: StaticString = #file, line: UInt = #line) {
        
        addTeardownBlock { [weak instanse] in
             
            XCTAssertNil(instanse, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}

