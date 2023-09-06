//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

final class FeedImageCellController {
    
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        
        let cell = binded(FeedImageCell())
        viewModel.loadImage()
        
        return cell
    }
    
    func preload() {
        
        viewModel.loadImage()
    }
    
    func cancelLoad() {
        
        viewModel.cancelLoad()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.locationLabel.text = viewModel.locationText
        cell.descriptionLabel.text = viewModel.descriptionText
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.onRetry = viewModel.loadImage
        
        viewModel.onImageLoad = { [weak cell] image in
            
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            
            switch isLoading {
            case true:
                cell?.feedImageContainer.startShimmering()
                
            case false:
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] isRetry in
            
            cell?.feedImageRetryButton.isHidden = !isRetry
        }
        
        return cell
    }
}
