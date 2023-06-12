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
    struct UnexpectedResultError: Error {}
    
    func get(from url: URL, completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        
        session.dataTask(with: url) { _, _, error in
            
            if let error {
                
                completion(.failure(error))
                
            } else {
                
                completion(.failure(UnexpectedResultError()))
            }
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
                
        let error = NSError(domain: "some error", code: 0)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "Waiting for callback")
        
        makeSUT().get(from: anyURL()) { result in
            
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
    }
    
    func test_getFromURL_failsOnAllNil() {
                
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "Waiting for callback")
        
        makeSUT().get(from: anyURL()) { result in
            
            switch result {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure got result: \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers Methods
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func anyURL() -> URL {
        
        URL(string: "http://some-url.com")!
    }
}

//MARK: - Helpers

private class URLProtocolStub: URLProtocol {
    
    private static var stub: Stub?
    private static var requestsObserver: ((URLRequest) -> Void)?
    
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
        stub = nil
        requestsObserver = nil
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        
        requestsObserver = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        requestsObserver?(request)
        
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

