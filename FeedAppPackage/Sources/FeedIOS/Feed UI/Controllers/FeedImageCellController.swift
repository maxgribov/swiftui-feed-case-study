//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit
import Feed

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

extension FeedImageViewModel {
    
    var image: Image? {
        
        switch imageState {
        case .image(let image):
            return image
            
        default:
            return nil
        }
    }
    
    var isLoading: Bool {
        
        switch imageState {
        case .loading:
            return true
            
        default:
            return false
        }
    }
    
    var shouldRetry: Bool {
        
        switch imageState {
        case .retry:
            return true
            
        default:
            return false
        }
    }
}
