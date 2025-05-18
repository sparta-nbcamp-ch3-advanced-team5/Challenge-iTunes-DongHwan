//
//  ContainerStackView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

/// 썸네일, `labelStackView` 컨테이너 `UIStackView`
final class ContainerStackView: UIStackView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.axis = .horizontal
        self.spacing = 10
        self.alignment = .center
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
