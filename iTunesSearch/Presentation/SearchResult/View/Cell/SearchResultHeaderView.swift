//
//  SearchResultHeaderView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/16/25.
//

import UIKit

import SnapKit
import Then

final class SearchResultHeaderView: UICollectionReusableView {
    
    // MARK: - UI Components
    
    /// Header 제목 UILabel
    private let titleLabel = TitleLabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
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
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - UI Methods

private extension SearchResultHeaderView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(titleLabel)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

