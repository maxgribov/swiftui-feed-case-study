//
//  FeedRefreshViewController.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {

        self.delegate = delegate
    }

    @objc
    func refresh() {
        
        delegate.didRequestFeedRefresh()
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
