//
//  File.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit
import Feed

final class FeedImageViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        
        self.model = model
        self.imageLoader = imageLoader
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
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImage() {
        
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] result in
            
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        
        if let image = (try? result.get()).flatMap(UIImage.init) {
            
            onImageLoad?(image)
            
        } else {
            
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelLoad() {
        
        task?.cancel()
    }
}

final class FeedImageCellController {
    
    private let viewModel: FeedImageViewModel
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        
        self.viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader)
    }
    
    func view() -> UITableViewCell {
        
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.locationLabel.text = viewModel.locationText
        cell.descriptionLabel.text = viewModel.descriptionText
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        
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

        cell.onRetry = { [weak self] in self?.viewModel.loadImage() }
        
        viewModel.loadImage()
        
        return cell
    }
    
    func preload() {
        
        viewModel.loadImage()
    }
    
    func cancelLoad() {
        
        viewModel.cancelLoad()
    }
}
