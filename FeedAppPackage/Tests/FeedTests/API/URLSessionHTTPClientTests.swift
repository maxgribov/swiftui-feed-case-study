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
        URLProtocolStub.stub(url: url, error: error)
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
    
    private static var stubs = [URL: Stub]()
    
    private struct Stub {

        let error: Error?
    }
    
    static func startInterceptingRequests() {
        
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    static func stub(url: URL, error: Error? = nil) {
        
        stubs[url] = Stub(error: error)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        
        guard let url = request.url else { return false }
        
        return URLProtocolStub.stubs[url] != nil
    }
   
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
            return
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

