//
//  FeedPresenterTests.swift
//  
//
//  Created by Max Gribov on 19.09.2023.
//

import XCTest

final class FeedPresenter {
    
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
     
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy {
        
        let messages = [Any]()
    }
}
