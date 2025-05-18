//
//  LabelStackView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

/// `UILabel` 컨테이너 `UIStackView`
final class LabelStackView: UIStackView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.axis = .vertical
        self.spacing = 2
        self.alignment = .leading
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
