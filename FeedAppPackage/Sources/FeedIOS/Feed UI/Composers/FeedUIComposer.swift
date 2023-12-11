//
//  FeedUIComposer.swift
//  
//
//  Created by Max Gribov on 06.09.2023.
//

import UIKit
import Combine
import Feed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: DummyErrorView())
        
        return feedController
    }
}

private final class DummyErrorView: FeedErrorView {
    
    func display(_ viewModel: FeedErrorViewModel) {
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
            let imagePresenter = FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(view: WeakRefVirtualProxy(imageController), imageTransformer: UIImage.init)
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
    
    var presenter: FeedPresenter?
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: AnyCancellable?
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink { [weak self] completion in
            
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
            
        } receiveValue: { [weak self] feed in
            
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }
    }
}

final class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        decoratee.loadImageData(from: url) {[weak self] result in
            
            self?.dispatch { completion(result) }
        }
    }
}
