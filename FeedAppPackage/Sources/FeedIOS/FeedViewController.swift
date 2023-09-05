//
//  FeedViewController.swift
//  
//
//  Created by Max Gribov on 05.09.2023.
//

import UIKit
import Feed

public final class FeedViewController: UITableViewController {
    
    var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc
    private func load() {
        
        refreshControl?.beginRefreshing()
        loader?.load() { [weak self] _ in
            
            self?.refreshControl?.endRefreshing()
        }
    }
}
