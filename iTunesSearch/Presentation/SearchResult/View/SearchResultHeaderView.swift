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
    
    // MARK: - Properties
    
    static let identifier = String(describing: SearchResultHeaderView.self)
    
    // MARK: - UI Components
    
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView()
    /// LabelStackView가 위쪽 간격을 갖도록 하는 UIView
    private let topSpacer = UIView.spacer(axis: .vertical)
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
        self.addSubview(labelStackView)
        
        labelStackView.addArrangedSubviews(topSpacer,
                                           titleLabel)
    }
    
    func setConstraints() {
        labelStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        topSpacer.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }
}

