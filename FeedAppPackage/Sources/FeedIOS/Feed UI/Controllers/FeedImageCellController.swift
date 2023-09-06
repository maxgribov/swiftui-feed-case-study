//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit
import Feed

final class FeedImageViewModel {
    
    private let model: FeedImage
    
    init(model: FeedImage) {
        self.model = model
    }
    
    var isLocationHidden: Bool {
        model.location == nil
    }
    
    var locationText: String? {
        model.location
    }
    
    var descriptionText: String? {
        model.description
    }
    
    var imageURL: URL {
        model.url
    }
}

final class FeedImageCellController {
    
    private let viewModel: FeedImageViewModel
    private var task: FeedImageDataLoaderTask?
    
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        
        self.viewModel = FeedImageViewModel(model: model)
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.locationLabel.text = viewModel.locationText
        cell.descriptionLabel.text = viewModel.descriptionText
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            
            guard let self else { return }
            
            self.task = self.imageLoader.loadImageData(from: viewModel.imageURL) {[weak cell] result in
                
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }

        loadImage()
        cell.onRetry = loadImage
        
        return cell
    }
    
    func preload() {
        
        task = imageLoader.loadImageData(from: viewModel.imageURL) { _ in }
    }
    
    func cancelLoad() {
        
        task?.cancel()
    }
}
