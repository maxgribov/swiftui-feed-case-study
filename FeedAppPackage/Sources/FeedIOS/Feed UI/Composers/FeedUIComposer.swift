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
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(refreshController))
        
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    
    func display(_ viewModel: FeedLoadingViewModel) {
        
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        
        controller?.tableModel = viewModel.feed.map { model in
            
            let imageController = FeedImageCellController()
            let imagePresenter = FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(view: WeakRefVirtualProxy(imageController), model: model, imageLoader: loader, imageTransformer: UIImage.init)
            imageController.delegate = FeedImagePresentationAdapter(model: model, imageLoader: loader, presenter: imagePresenter)

            return imageController
        }
    }
}

private final class FeedImagePresentationAdapter: FeedImageCellControllerDelegate {
    
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let presenter: FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, presenter: FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>) {
        
        self.model = model
        self.imageLoader = imageLoader
        self.presenter = presenter
    }
    
    func loadImage() {
        
        presenter.didStartLoadingImage(for: model)
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .success(data):
                presenter.didFinishLoadingImage(for: model, with: data)
                
            case let .failure(error):
                presenter.didFinishLoadingImage(for: model, with: error)
            }
        }
    }
    
    func cancelLoad() {
        
        task?.cancel()
        presenter.didCancelledLoadingImage(for: model)
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
