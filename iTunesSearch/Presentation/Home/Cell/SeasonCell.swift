//
//  SeasonCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import SnapKit
import Then

final class SeasonCell: UICollectionViewCell {
    
    // MARK: - UI Componenets
    
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .placeholderText
        $0.layer.cornerRadius = 15
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "Save Me, Save You"
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private let artistLabel = UILabel().then {
        $0.text = "WJSN"
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private let collectionLabel = UILabel().then {
        $0.text = "WJ Please? - EP"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
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
    
    func configure(thumbnailImage: UIImage, title: String, artist: String, collection: String) {
        thumbnailImageView.image = thumbnailImage
        titleLabel.text = title
        artistLabel.text = artist
        collectionLabel.text = collection
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
                         collectionLabel)
    }
    
    func setConstraints() {
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
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
    }
}
