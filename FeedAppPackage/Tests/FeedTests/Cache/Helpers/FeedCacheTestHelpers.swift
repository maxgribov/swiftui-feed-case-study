//
//  FeedCacheTestHelpers.swift
//  
//
//  Created by Max Gribov on 03.08.2023.
//

import Foundation

extension Date {
    
    func minusFeedCacheMaxAge() -> Date {
        
        adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        
        self + seconds
    }
}

