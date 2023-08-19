//
//  FeedImageViewModel.swift
//  
//
//  Created by Max Gribov on 17.08.2023.
//

import Foundation

public final class FeedImageViewModel: Identifiable, ObservableObject {

    public let id: UUID
    public let description: String?
    public let location: String?
    @Published public private(set) var imageData: ImageData
    
    public var isImageDataLoading: Bool {
        
        guard case .load(_) = imageData else {
            return false
        }
        
        return true
    }
    
    public init(id: UUID, description: String?, location: String?, imageData: ImageData) {
        self.id = id
        self.description = description
        self.location = location
        self.imageData = imageData
    }
    
    public enum ImageData {
        
        case load(URL)
        case loaded(Data)
        case fail
    }
    
    func updateLoaded(imageData: Data?) {
        
        if let imageData {
            
            self.imageData = validate(imageData: imageData) ? .loaded(imageData) : .fail
            
        } else {
            
            self.imageData = .fail
        }
    }
    
    private func validate(imageData: Data) -> Bool {
        
        // check if data can be converted to Image
        return true
    }
}
