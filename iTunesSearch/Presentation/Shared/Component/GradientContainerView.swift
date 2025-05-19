//
//  GradientContainerView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/19/25.
//

import UIKit

import SnapKit

/// 그라디엔트 처리된 블러를 배경으로 하는 컨테이너 `UIView`
final class GradientContainerView: UIView {
    
    // MARK: - Properties
    
    var startPoint: CGPoint = .init(x: 0.0, y: 0.0) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    var endPoint: CGPoint = .init(x: 0.0, y: 0.5) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    // MARK: - UI Components
    
    /// 블러 그라데이션 처리용 `CAGradientLayer`
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setGradientMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰 크기가 변할 때마다 마스크 크기 업데이트
        gradientLayer.frame = self.bounds
    }
}

// MARK: - Setting Methods

private extension GradientContainerView {
    func setGradientMask() {
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor
        ]
        
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        gradientLayer.frame = self.bounds
        
        self.layer.addSublayer(gradientLayer)
    }
}
