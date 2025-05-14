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
    
    // MARK: - Properties
    
    static let identifier = String(describing: HomeHeaderView.self)
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "봄 Best"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .label
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "봄에 어울리는 음악 Best 5"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
    }
    
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

// MARK: - UI Methods

private extension HomeHeaderView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(titleLabel,
                         subtitleLabel)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-2)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
