//
//  RemoteFeedLoaderTests.swift
//  
//
//  Created by Max Gribov on 25.05.2023.
//

import XCTest
import Feed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (_, client) = makeSUT(url: url)

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL =  URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}




