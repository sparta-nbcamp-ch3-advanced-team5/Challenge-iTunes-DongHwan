//
//  SeasonCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import SnapKit
import Then

/// 홈 화면 CollectionView 여름, 가을, 겨울 셀
final class SeasonCell: UICollectionViewCell {
    
    // MARK: - UI Componenets
    
    /// 앨범 썸네일 UIImageView
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .placeholderText
        $0.layer.cornerRadius = 15
    }
    
    /// 노래 제목 UILabel
    private let titleLabel = UILabel().then {
        $0.text = "Save Me, Save You"
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    /// 가수 이름 UILabel
    private let artistLabel = UILabel().then {
        $0.text = "WJSN"
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    /// 앨범 이름 UILabel
    private let collectionLabel = UILabel().then {
        $0.text = "WJ Please? - EP"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .separator
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
    
    func configure(thumbnailImage: UIImage, title: String, artist: String, collection: String, isBottom: Bool) {
        thumbnailImageView.image = thumbnailImage
        titleLabel.text = title
        artistLabel.text = artist
        collectionLabel.text = collection
        separatorView.isHidden = isBottom
    }
}

// MARK: - UI Methods

private extension SeasonCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(thumbnailImageView, titleLabel,
                         artistLabel,
                         collectionLabel,
                         separatorView)
    }
    
    func setConstraints() {
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(artistLabel)
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(artistLabel.snp.top).offset(-2)
        }
        
        artistLabel.snp.makeConstraints {
            $0.centerY.equalTo(thumbnailImageView)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        collectionLabel.snp.makeConstraints {
            $0.top.equalTo(artistLabel.snp.bottom).offset(2)
            $0.leading.equalTo(artistLabel)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        separatorView.snp.makeConstraints {
            $0.leading.equalTo(artistLabel)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}
