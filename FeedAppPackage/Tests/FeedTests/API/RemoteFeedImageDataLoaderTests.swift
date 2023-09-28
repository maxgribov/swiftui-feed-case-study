//
//  RemoteFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 28.09.2023.
//

import XCTest
import Feed

final class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        client.get(from: url) { result in
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
                
            default:
                break
            }
        }
        
        return Task()
    }
    
    struct Task: FeedImageDataLoaderTask {
        
        func cancel() {
            
        }
    }
    
    enum Error: Swift.Error {
        case connectivity
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotSendAnyRequest() {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        XCTAssertEqual(client.requests.count, 0)
    }
    
    func test_loadImageData_returnConnectivityErrorOnClientError() {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        let exp = expectation(description: "Request completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            
            exp.fulfill()
            
            switch result {
            case let .failure(error):
                guard let imageLoaderError = error as? RemoteFeedImageDataLoader.Error else {
                    return XCTFail("Expected image loader error, got \(error) instead")
                }
                guard imageLoaderError == .connectivity else {
                    return XCTFail("Expected connectivity error, got \(imageLoaderError) instead")
                }
                
                break
            
            default:
                XCTFail("Expected connectivity error, got \(result) instead")
            }
        }
        
        client.complete(with: anyNSError())
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    class HTTPClientSpy: HTTPClient {
        
        private(set) var requests = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
            requests.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            requests[index].completion(.failure(error))
        }
    }
}
