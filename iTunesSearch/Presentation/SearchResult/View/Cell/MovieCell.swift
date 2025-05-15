//
//  MovieCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit
import OSLog

import RxSwift
import SnapKit
import Then

/// 검색 결과 CollectionView 영화 Cell
final class MovieCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 배경 사진 UIImageView(API에 배경 사진이 없으므로 배경색만 변경)
    private let backgroundImageView = BackgroundImageView(frame: .zero)
    
    /// 영화 썸네일 UIImageView
    private let thumnailImageView = ThumbnailImageView(frame: .zero)
    
    /// LabelStackView, Button 컨테이너 UIStackView
    private let containerStackView = ContainerStackView()
    
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView()
    
    /// 영화 제목 UILabel
    private let titleLabel = TitleLabel()
    
    /// 영화 장르 UILabel
    private let genreLabel = SubtitleLabel()
    
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
    
    func configure(thumbnailImageURL: String, backgroundImageColor: UIColor, title: String, genre: String) {
        backgroundImageView.backgroundColor = backgroundImageColor
        titleLabel.text = title
        genreLabel.text = genre
    }
}

// MARK: - UI Methods

private extension MovieCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(backgroundImageView,
                         thumnailImageView,
                         containerStackView)
        
        containerStackView.addArrangedSubviews(labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           genreLabel)
    }
    
    func setConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumnailImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.width.height.equalTo(90)
        }
        
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
}
