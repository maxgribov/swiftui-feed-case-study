//
//  HTTPClient.swift
//  
//
//  Created by Max Gribov on 10.06.2023.
//

import Foundation

public enum HTTPClientResult {
    
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    /// The completion handler con be invoked in any thread.
    /// Cliens are responsable to dispatch to approtpiate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
