//
//  SubtitleLabel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

final class SubtitleLabel: UILabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.text = "Park Bom"
        self.font = .systemFont(ofSize: 14)
        self.textColor = .secondaryLabel
        self.numberOfLines = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
