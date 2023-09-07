//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit

final class FeedImageCellController: FeedImageView {

    private let presenter: FeedImagePresenter<FeedImageCellController, UIImage>
    private let cell = FeedImageCell()
    
    init(presenter: FeedImagePresenter<FeedImageCellController, UIImage>) {
        self.presenter = presenter
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        
        cell.update(with: viewModel, onRetry: { [weak presenter] in presenter?.loadImage()})
    }
    
    func view() -> UITableViewCell {
        
        presenter.loadImage()
        
        return cell
    }
    
    func preload() {
        
        presenter.loadImage()
    }
    
    func cancelLoad() {
        
        presenter.cancelLoad()
    }
}

extension FeedImageCell {
    
    func update(with viewModel: FeedImageViewModel<UIImage>, onRetry: @escaping () -> Void) {
        
        locationContainer.isHidden = viewModel.isLocationHidden
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
