//
//  FeedRefreshViewController.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    private let loadFeed: () -> Void
    
    init(loadFeed: @escaping () -> Void) {

        self.loadFeed = loadFeed
    }

    @objc
    func refresh() {
        
        loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        
        switch viewModel.isLoading {
        case true:
            view.beginRefreshing()
            
        case false:
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
