//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    
    func loadImage()
    func cancelLoad()
}

final class FeedImageCellController: FeedImageView {

    private let cell = FeedImageCell()
    var delegate: FeedImageCellControllerDelegate?
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        
        cell.update(with: viewModel, onRetry: { [weak self] in self?.delegate?.loadImage() })
    }
    
    func view() -> UITableViewCell {
        
        delegate?.loadImage()
        
        return cell
    }
    
    func preload() {
        
        delegate?.loadImage()
    }
    
    func cancelLoad() {
        
        delegate?.cancelLoad()
    }
}

extension FeedImageCell {
    
    func update(with viewModel: FeedImageViewModel<UIImage>, onRetry: @escaping () -> Void) {
        
        locationContainer.isHidden = viewModel.locationText == nil
        locationLabel.text = viewModel.locationText
        descriptionLabel.text = viewModel.descriptionText
        feedImageView.image = viewModel.image
        self.onRetry = onRetry

        switch viewModel.isLoading {
        case true:
            feedImageContainer.startShimmering()
            
        case false:
            feedImageContainer.stopShimmering()
        }
        
        feedImageRetryButton.isHidden = !viewModel.shouldRetry
    }
}
