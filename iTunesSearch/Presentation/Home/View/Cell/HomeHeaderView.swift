//
//  HomeHeaderView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import UIKit

import SnapKit
import Then

/// 홈 화면 CollectionView Header
final class HomeHeaderView: UICollectionReusableView {
    
    // MARK: - UI Components
    
    /// `UILabel` 컨테이너 `UIStackView`
    private let labelStackView = LabelStackView()
    /// `Header` 제목 `UILabel`
    private let titleLabel = TitleLabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }
    /// Header 부제목 `UILabel`
    private let subtitleLabel = SubtitleLabel()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - Setting Methods

private extension HomeHeaderView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           subtitleLabel)
    }
    
    func setConstraints() {
        labelStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
