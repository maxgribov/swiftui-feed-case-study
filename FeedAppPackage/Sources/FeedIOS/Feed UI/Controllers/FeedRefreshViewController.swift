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
        
        viewModel.onLoadingStateChange = {[weak view] isLoading in
            
            switch isLoading {
            case true:
                view?.beginRefreshing()
                
            case false:
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
