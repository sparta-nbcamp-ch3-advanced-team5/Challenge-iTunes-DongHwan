//
//  ThumbnailImageView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

/// 썸네일 UIImageView
final class ThumbnailImageView: UIImageView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
