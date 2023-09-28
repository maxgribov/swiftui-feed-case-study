//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Max Gribov on 12.06.2023.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedResultError: Error {}
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        let task = session.dataTask(with: url) { data, response, error in
            
            completion(Result {
                
                if let error {
                    
                    throw error
                    
                } else if let data, let response = response as? HTTPURLResponse {
                    
                    return (data, response)
                    
                } else {
                    
                    throw UnexpectedResultError()
                }
            })
        }
        task.resume()
        
        return task
    }
}

extension URLSessionDataTask: HTTPClientTask {}
