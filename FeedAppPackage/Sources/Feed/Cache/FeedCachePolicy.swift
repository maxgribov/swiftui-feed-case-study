//
//  FeedCachePolicy.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation

final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
        return date < maxCacheAge
    }
}
