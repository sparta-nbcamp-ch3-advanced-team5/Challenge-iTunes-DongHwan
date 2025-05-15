//
//  PodcastCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import UIKit
import OSLog

import RxSwift
import SnapKit
import Then

/// 검색 결과 CollectionView 팟캐스트 Cell
final class PodcastCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 팟캐스트 썸네일 UIImageView
    private let thumnailImageView = ThumbnailImageView(frame: .zero)
    
    /// LabelStackView, Button 컨테이너 UIStackView
    private let containerStackView = ContainerStackView()
    
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView()
    
    /// 팟캐스트 마케팅 문구 UILabel
    private let marketingPhrasesLabel = SubtitleLabel()
    
    /// 팟캐스트 제목 UILabel
    private let titleLabel = TitleLabel()
    
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
    
    func configure(thumbnailImageURL: String, marketingPhrases: String, title: String) {
        marketingPhrasesLabel.text = marketingPhrases
        titleLabel.text = title
    }
}

// MARK: - UI Methods

private extension PodcastCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(thumnailImageView,
                         containerStackView)
        
        containerStackView.addArrangedSubviews(labelStackView)
        
        labelStackView.addArrangedSubviews(marketingPhrasesLabel,
                                           titleLabel)
    }
    
    func setConstraints() {
        thumnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(15)
            $0.height.equalTo(60)
        }
    }
}
