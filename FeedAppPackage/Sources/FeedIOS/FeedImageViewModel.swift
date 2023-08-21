//
//  FeedImageViewModel.swift
//  
//
//  Created by Max Gribov on 17.08.2023.
//

import Foundation
import CoreGraphics

public final class FeedImageViewModel: Identifiable, ObservableObject {

    public let id: UUID
    public let description: String?
    public let location: String?
    @Published public private(set) var imageData: ImageData
    let onRetry: () -> Void
    
    public var isImageDataLoading: Bool {
        
        guard case .load(_) = imageData else {
            return false
        }
        
        return true
    }
    
    public init(id: UUID, description: String?, location: String?, imageData: ImageData, onRetry: @escaping () -> Void) {
        
        self.id = id
        self.description = description
        self.location = location
        self.imageData = imageData
        self.onRetry = onRetry
    }
    
    public enum ImageData {
        
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
    
    public func retryButtonDidTapped() {
        
        onRetry()
    }
    
    func updateLoaded(url: URL, imageData: Data?) {
        
        if let imageData {
            
            self.imageData = validate(imageData: imageData) ? .loaded(imageData) : .fail(url)
            
        } else {
            
            self.imageData = .fail(url)
        }
    }
    
    private func validate(imageData: Data) -> Bool {
        
        return CGImage.image(fromPng: imageData) != nil
    }
}
