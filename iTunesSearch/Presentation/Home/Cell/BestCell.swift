//
//  BestCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import SnapKit
import Then

/// 홈 화면 Music 봄 Best 셀
final class BestCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let albumImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        $0.image = UIImage(systemName: "music.note", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        $0.contentMode = .center
        $0.backgroundColor = .placeholderText
        $0.layer.cornerRadius = 10
    }
    
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "봄 (feat. Sandara Park)"
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private let artistLabel = UILabel().then {
        $0.text = "Park Bom"
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
    
    func configure(albumImage: UIImage?, thumbnailImage: UIImage, title: String, artist: String) {
        if let albumImage {
            albumImageView.image = albumImage
        }
        thumbnailImageView.image = thumbnailImage
        titleLabel.text = title
        artistLabel.text = artist
    }
}

// MARK: - UI Methods

private extension BestCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(albumImageView,
                         thumbnailImageView, titleLabel,
                         artistLabel)
    }
    
    func setConstraints() {
        albumImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(15)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(artistLabel)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(artistLabel.snp.top).offset(-2)
        }
        
        artistLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(thumbnailImageView)
        }
    }
}
