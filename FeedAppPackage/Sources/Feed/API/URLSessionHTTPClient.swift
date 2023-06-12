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
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            
            if let error {
                
                completion(.failure(error))
                
            } else if let data, let response = response as? HTTPURLResponse {
                
                completion(.success(data, response))
                
            } else {
                
                completion(.failure(UnexpectedResultError()))
            }
            
        }.resume()
    }
}
