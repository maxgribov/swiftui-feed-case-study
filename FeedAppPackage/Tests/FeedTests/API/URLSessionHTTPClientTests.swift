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
    
    init(session: URLSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "http://some-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let url = URL(string: "http://some-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "some error", code: 0)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Waiting for callback")
        
        sut.get(from: url) { result in
            
            switch result {
            case let .failure(resultError as NSError):
                XCTAssertEqual(resultError, error)
                
            default:
                XCTFail("Expected error: \(error) got result: \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
}

//MARK: - Helpers

private class URLSessionSpy: URLSession {
    
    private var stubs = [URL: Stub]()
    
    private struct Stub {
        
        let task: URLSessionDataTask
        let error: Error?
    }
    
    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
        
        stubs[url] = Stub(task: task, error: error)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        guard let stub = stubs[url] else {
            fatalError("Expected stub")
        }
        
        completionHandler(nil , nil, stub.error)
        
        return stub.task
    }
}

private class FakeURLSessionDataTask: URLSessionDataTask {
    
    override func resume() {}
}

private class URLSessionDataTaskSpy: URLSessionDataTask {
    
    var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount += 1
    }
}
