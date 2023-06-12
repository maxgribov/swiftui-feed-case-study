//
//  URLSessionHTTPClientTests.swift
//  
//
//  Created by Max Gribov on 11.06.2023.
//

import XCTest
import Feed

final class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        
        session.dataTask(with: url) { _, _, error in
            
            if let error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://some-url.com")!
        let error = NSError(domain: "some error", code: 0)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Waiting for callback")
        
        sut.get(from: url) { result in
            
            switch result {
            case let .failure(resultError as NSError):
                XCTAssertEqual(resultError.code, error.code)
                XCTAssertEqual(resultError.domain, error.domain)
                
            default:
                XCTFail("Expected error: \(error) got result: \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.stopInterceptingRequests()
    }
}

//MARK: - Helpers

private class URLProtocolStub: URLProtocol {
    
    private static var stub: Stub?
    
    private struct Stub {

        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func startInterceptingRequests() {
        
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        
        stub = Stub(data: data, response: response, error: error)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
   
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

