//
//  TitleLabel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

final class TitleLabel: UILabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.text = "봄 (feat. Sandara Park)"
        self.font = .systemFont(ofSize: 17, weight: .semibold)
        self.textColor = .label
        self.numberOfLines = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
