//
//  File.swift
//  
//
//  Created by Max Gribov on 03.10.2023.
//

import Foundation
import Feed

final class HTTPClientSpy: HTTPClient {
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var requestedURLs: [URL] { messages.map(\.url) }
    
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        messages.append((url, completion))
        return Task()
    }
    
    func complete(with error: Error, at index: Int = 0) {
        
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data,  at index: Int = 0) {
        
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
    
    struct Task: HTTPClientTask {
        func cancel() {
        }
    }
}
