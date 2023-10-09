//
//  SharedTestHelpers.swift
//  
//
//  Created by Max Gribov on 08.08.2023.
//

import Foundation

func anyURL() -> URL {
    
    URL(string: "http://some-url.com")!
}

func anyNSError() -> NSError {
    
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    
    Data("any data".utf8)
}


