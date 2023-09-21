//
//  FeedImagePresenterTests.swift
//  
//
//  Created by Max Gribov on 21.09.2023.
//

import XCTest

protocol FeedImageView {
    
}

final class FeedImagePresenter {
    
    init(view: FeedImageView) {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSentMessagesToView() {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private class ViewSpy: FeedImageView {
        
        let messages = [Any]()
    }
}
