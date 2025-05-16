//
//  ThumbnailView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

import SnapKit
import Then

/// 썸네일과 관련된 UI를 갖고있는 `UIView`
final class ThumbnailView: UIView {
    
    // MARK: - UI Components
    
    /// 썸네일 `UIImageView`
    private let thumbnailImageView = UIImageView().then {
        $0.alpha = 0.0
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.center = self.center
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }
    
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Getter
    
    var getThumbnailImageView: UIImageView {
        return thumbnailImageView
    }
    
    var getActivityIndicator: UIActivityIndicatorView {
        return activityIndicator
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

// MARK: - Setting Methods

private extension ThumbnailView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
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

// MARK: - Private Methods

private extension ThumbnailView {
    func fadeInAnimation() {
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0, animations: {
            self.thumbnailImageView.alpha = 1.0
        })
    }
}
