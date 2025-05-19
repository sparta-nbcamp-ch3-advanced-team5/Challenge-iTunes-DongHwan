//
//  GoToButton.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/16/25.
//

import UIKit

/// 사파리로 이동하는 버튼
final class GoToButton: UIButton {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var config = UIButton.Configuration.gray()
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        config.attributedTitle = AttributedString("이동", attributes: titleContainer)
        config.cornerStyle = .capsule
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
