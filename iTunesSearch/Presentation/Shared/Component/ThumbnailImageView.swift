//
//  ThumbnailImageView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

import SnapKit
import Then

/// 썸네일 UIImageView
final class ThumbnailImageView: UIImageView {
    
    // MARK: - UI Components
    
    lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.center = self.center
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ThumbnailImageView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
    func setViewHierarchy() {
        self.addSubview(activityIndicator)
    }
    
    func setConstraints() {
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
