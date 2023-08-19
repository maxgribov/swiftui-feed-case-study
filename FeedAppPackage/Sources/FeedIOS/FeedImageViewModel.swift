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
    @Published public var imageData: ImageData
    
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
}
