//
//  File.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation

func anyURL() -> URL {
    
    URL(string: "http://some-url.com")!
}

func anyNSError() -> NSError {
    
    NSError(domain: "any error", code: 0)
}
