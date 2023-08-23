//
//  FeedImageViewModel.swift
//  
//
//  Created by Max Gribov on 17.08.2023.
//

import Foundation
import CoreGraphics
import Feed

public final class FeedImageViewModel: Identifiable, ObservableObject {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    @Published public private(set) var imageData: ImageData
    
    private let onRetry: () -> Void
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    public init(feedImage: FeedImage, imageLoader: FeedImageDataLoader, onRetry: @escaping () -> Void) {
        
        self.id = feedImage.id
        self.description = feedImage.description
        self.location = feedImage.location
        self.imageData = .load(feedImage.url)
        self.onRetry = onRetry
        self.imageLoader = imageLoader
    }

    public func loadImage() {
        
        guard let url = imageData.url else {
            return
        }
        
        task = imageLoader.loadImageData(from: url) {[weak self] result in
            
            switch result {
            case let .success(data):
                self?.updateLoaded(url: url, imageData: data)
                
            case .failure:
                self?.updateLoaded(url: url, imageData: nil)
            }
        }
    }
    
    public func cancelImageLoad() {
        
        task?.cancel()
        task = nil
    }
    
    public func retryButtonDidTapped() {
        
        onRetry()
    }
}

public extension FeedImageViewModel {
    
    enum ImageData {
        
        case load(URL)
        case loaded(Data)
        case fail(URL)
        
        var url: URL? {
            
            switch self {
            case let .load(url): return url
            case let .fail(url): return url
            default: return nil
            }
        }
    }
    
    var isImageDataLoading: Bool {
        
        guard case .load(_) = imageData else {
            return false
        }
        
        return true
    }
}

private extension FeedImageViewModel {
    
    func updateLoaded(url: URL, imageData: Data?) {
        
        if let imageData {
            
            self.imageData = validate(imageData: imageData) ? .loaded(imageData) : .fail(url)
            
        } else {
            
            self.imageData = .fail(url)
        }
    }
    
    func validate(imageData: Data) -> Bool {
        
        return CGImage.image(fromPng: imageData) != nil
    }
}
