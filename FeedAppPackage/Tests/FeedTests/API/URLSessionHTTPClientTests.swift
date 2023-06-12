//
//  URLSessionHTTPClientTests.swift
//  
//
//  Created by Max Gribov on 11.06.2023.
//

import XCTest
import Feed

final class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedResultError: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            
            if let error {
                
                completion(.failure(error))
                
            } else if let data, let response = response as? HTTPURLResponse {
                
                completion(.success(data, response))
                
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
    
    override func tearDown() {
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
                
        let requestError = anyNSError()
        let resultError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        
        XCTAssertEqual(resultError?.code, requestError.code)
        XCTAssertEqual(resultError?.domain, requestError.domain)
    }
    
    func test_getFromURL_failsOnAllInvalidCases() {
                
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_successOnDataAndHTTPURLResponse() {

        let data = anyData()
        let response = anyHTTPURLResponse()

        let resultValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(resultValues?.data, data)
        XCTAssertEqual(resultValues?.response.url, response.url)
        XCTAssertEqual(resultValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_successWithEmptyDataOnHTTPURLResponseWithNilData() {

        let response = anyHTTPURLResponse()
        
        let resultValues = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(resultValues?.data, emptyData)
        XCTAssertEqual(resultValues?.response.url, response.url)
        XCTAssertEqual(resultValues?.response.statusCode, response.statusCode)
    }
    
    //MARK: - Helpers Methods
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func anyURL() -> URL {
        
        URL(string: "http://some-url.com")!
    }
    
    private func anyData() -> Data {
        
        Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        
        HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
            
        default:
            XCTFail("Expected success got result: \(result)", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
            
        default:
            XCTFail("Expected failure got result: \(result)", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Waiting for callback")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
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

