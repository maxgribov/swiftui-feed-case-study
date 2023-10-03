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
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        
        let (sut, client) = makeSUT()
        let url = URL(string: "http://some-url.com")!
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageData_requestDataFromURLTwice() {
        
        let (sut, client) = makeSUT()
        let url = URL(string: "http://some-url.com")!
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_returnConnectivityErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, result: failure(.connectivity)) {
            client.complete(with: clientError)
        }
    }
    
    func test_loadImageData_returnInvalidDataErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        let samples = [100, 199, 201, 400, 404]
        
        samples.enumerated().forEach { (index, status) in
            expect(sut, result: failure(.invalidData)) {
                client.complete(withStatusCode: status, data: anyData(), at: index)
            }
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
        
    private func expect(_ sut: RemoteFeedImageDataLoader, result expectedResult: FeedImageDataLoader.Result, on action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Request completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyData() -> Data { Data() }
    
    func failure( _ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
}
