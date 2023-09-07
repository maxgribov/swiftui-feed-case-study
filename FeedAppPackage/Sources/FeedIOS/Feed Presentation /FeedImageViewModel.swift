//
//  FeedImageViewModel.swift
//  
//
//  Created by Max Gribov on 07.09.2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    
    let locationText: String?
    let descriptionText: String?
    let imageState: ImageState
    
    enum ImageState {
        
        case image(Image)
        case loading
        case retry
    }
}

extension FeedImageViewModel {
    
    var image: Image? {
        
        switch imageState {
        case let .image(image): return image
        default: return nil
        }
    }
    
    var isLoading: Bool {
        
        switch imageState {
        case .loading: return true
        default: return false
        }
    }
    
    var shouldRetry: Bool {
        
        switch imageState {
        case .retry: return true
        default: return false
        }
    }
}
