//
//  FeedImageViewModel.swift
//  
//
//  Created by Max Gribov on 17.08.2023.
//

import Foundation

public struct FeedImageViewModel: Identifiable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageData: ImageData
    
    public enum ImageData {
        
        case load(URL)
        case loaded(Data)
    }
}
