//
//  MovieCollectionCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit
import OSLog

import RxSwift
import SnapKit
import Then

/// 검색 결과 CollectionView 영화 컬렉션 Cell
final class MovieCollectionCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 영화 썸네일 UIImageView
    private let thumnailImageView = ThumbnailImageView(frame: .zero)
    
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView()
    
    /// 영화 제목 UILabel
    private let titleLabel = TitleLabel()
    
    /// 영화 개봉 연도, 장르 UILabel
    private let yearGenreLabel = SubtitleLabel()
    
    // TODO: - 아이튠즈 연결 버튼 추가
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(title: String, year: String, genre: String) {
        titleLabel.text = title
        yearGenreLabel.text = "\(year)년 • \(genre)"
    }
}

// MARK: - UI Methods

private extension MovieCollectionCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(thumnailImageView,
                         labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           yearGenreLabel)
    }
    
    func setConstraints() {
        thumnailImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.width.height.equalTo(100)
        }
        
        labelStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
}
