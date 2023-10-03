//
//  RemoteFeedImageDataLoaderTests.swift
//  
//
//  Created by Max Gribov on 28.09.2023.
//

import XCTest
import Feed

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
    
    func test_loadImageData_returnInvalidDataErrorOn200HTTPResponseAndEmptyData() {
        
        let (sut, client) = makeSUT()
        
        let emptyData = Data()
        expect(sut, result: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageData_deliversReceivedNonEmptyDataOn200HTTPReaonse() {
        
        let (sut, client) = makeSUT()
        
        let nonEmptyData = nonEmptyData()
        expect(sut, result: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_cancelLoadImageDataTask_cancelsClientURLRquqest() {
        
        let (sut, client) = makeSUT()
        let url = URL(string: "http://some-url.com")!
        
        let task = sut.loadImageData(from: url) {_ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty)
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    func test_loadImageDataTask_doesNotDeliversResultAfterCancellingTask() {
        
        let (sut, client) = makeSUT()
        
        var results = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { results.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(results.isEmpty, "Expected empty results, got \(results)")
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceDeallocated() {
        
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var results = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { results.append($0) }
        sut = nil
        
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(results.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: FeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        
        return (sut, client)
    }
        
    private func expect(_ sut: FeedImageDataLoader, result expectedResult: FeedImageDataLoader.Result, on action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
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
    private func nonEmptyData() -> Data { Data("Non empty".utf8) }
    
    func failure( _ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
}
