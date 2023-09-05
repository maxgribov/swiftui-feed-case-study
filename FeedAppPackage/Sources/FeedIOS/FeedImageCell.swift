//
//  FeedImageCell.swift
//  
//
//  Created by Max Gribov on 05.09.2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    public private(set) lazy var feedImageRetryButton: UIButton = {
       
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    private func retryButtonTapped() {
        
        onRetry?()
    }
}
