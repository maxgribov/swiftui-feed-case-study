//
//  FeedRefreshViewController.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        
        self.presenter = presenter
    }

    @objc
    func refresh() {
        
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        
        switch isLoading {
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
