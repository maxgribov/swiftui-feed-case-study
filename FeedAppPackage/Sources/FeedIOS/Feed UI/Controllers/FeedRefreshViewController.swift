//
//  FeedRefreshViewController.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        
        self.viewModel = viewModel
    }

    @objc
    func refresh() {
        
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        
        viewModel.onChange = {[weak self] viewModel in
            
            switch viewModel.isLoading {
            case true:
                self?.view.beginRefreshing()
                
            case false:
                self?.view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
