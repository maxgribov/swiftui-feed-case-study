//
//  URLSessionHTTPClientTests.swift
//  
//
//  Created by Max Gribov on 11.06.2023.
//

import XCTest

final class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        
        session.dataTask(with: url) { _, _, _ in }
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        
        let url = URL(string: "http://some-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
}

//MARK: - Helpers

private class URLSessionSpy: URLSession {
    
    var receivedURLs = [URL]()
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        receivedURLs.append(url)
        
        return FakeURLSessionDataTask()
    }
}

private class FakeURLSessionDataTask: URLSessionDataTask {}
