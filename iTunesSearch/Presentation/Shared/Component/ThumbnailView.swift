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
    
    // MARK: - Properties
    
    private let placeholderImage = UIImage(systemName: "photo.badge.exclamationmark")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    
    // MARK: - UI Components
    
    /// 썸네일 `UIImageView`
    private let imageView = UIImageView().then {
        $0.alpha = 0.0
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .placeholderText
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    /// 로딩 애니메이션 `UIActivityIndicatorView`
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.center = self.center
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }
    
    /// 페이딩 애니메이션 `UIViewPropertyAnimator`
    private var animator: UIViewPropertyAnimator?
    
    // MARK: - Getter
    
    /// 썸네일 `UIimageView` 반환
    var getimageView: UIImageView {
        return imageView
    }
    
    /// 로딩 애니메이션 `UIActivityIndicatorView` 반환
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
        setAnimator()
    }
    
    func setViewHierarchy() {
        self.addSubviews(imageView,
                         activityIndicator)
    }
    
    func setConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    func setAnimator() {
        animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
            self.imageView.alpha = 1.0
        }
    }
}

// MARK: - Methods

extension ThumbnailView {
    /// 썸네일을 `placeholderImage` 로 변경
    func setPlaceholder() {
        imageView.image = placeholderImage
        imageView.contentMode = .center
    }
    
    /// 셀 재사용 시 초기화
    func prepareForReuse() {
        imageView.image = nil
        activityIndicator.startAnimating()
        animator?.stopAnimation(true)
    }
    
    /// 썸네일 Fade In 애니메이션
    func startFadeInAnimation() {
        animator?.startAnimation()
    }
}
