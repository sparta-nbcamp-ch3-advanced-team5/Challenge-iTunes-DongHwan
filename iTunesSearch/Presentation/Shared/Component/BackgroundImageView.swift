//
//  BackgroundImageView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

/// 배경 ImageView
final class BackgroundImageView: UIImageView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .placeholderText
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
