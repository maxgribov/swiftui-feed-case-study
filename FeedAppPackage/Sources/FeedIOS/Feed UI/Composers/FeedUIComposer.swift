//
//  FeedUIComposer.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit
import Feed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = {[weak feedController] feed in
            
            feedController?.tableModel = feed.map { model in
                
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
