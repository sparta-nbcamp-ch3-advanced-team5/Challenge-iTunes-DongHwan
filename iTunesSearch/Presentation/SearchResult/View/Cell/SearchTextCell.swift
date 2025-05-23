//
//  SearchTextCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit

import RxSwift
import SnapKit
import Then

/// 검색 결과 CollectionView 검색어 Cell
final class SearchTextCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 검색어 `UILabel`
    private let searchTextLabel = TitleLabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .bold)
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
    
    func configure(searchText: String) {
        searchTextLabel.text = searchText
    }
}

// MARK: - Setting Methods

private extension SearchTextCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubview(searchTextLabel)
    }
    
    func setConstraints() {
        searchTextLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
