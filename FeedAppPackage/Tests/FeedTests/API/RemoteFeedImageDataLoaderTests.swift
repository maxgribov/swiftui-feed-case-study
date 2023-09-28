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
                
            case .success:
                completion(.failure(Error.invalidData))
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
        case invalidData
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotSendAnyRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requests.count, 0)
    }
    
    func test_loadImageData_returnConnectivityErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, error: .connectivity) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_loadImageData_returnInvalidDataErrorOnInvalidDataFromClient() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, error: .invalidData) {
            client.complete(with: invalidData)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        private(set) var requests = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
            requests.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            requests[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            
            requests[index].completion(.success((data, HTTPURLResponse())))
        }
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, error expectedError: RemoteFeedImageDataLoader.Error, on action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Request completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            
            exp.fulfill()
            
            switch result {
            case let .failure(error):
                guard let receivedError = error as? RemoteFeedImageDataLoader.Error else {
                    return XCTFail("Expected image loader error, got \(error) instead", file: file, line: line)
                }
                guard receivedError == expectedError else {
                    return XCTFail("Expected \(expectedError) error, got \(receivedError) instead", file: file, line: line)
                }
                
                break
            
            default:
                XCTFail("Expected connectivity error, got \(result) instead", file: file, line: line)
            }
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private var invalidData: Data { Data() }
}
