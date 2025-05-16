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

/// 검색 결과 CollectionView 영화 컬렉션 Cell
final class MovieCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 썸네일, LabelStackView 컨테이너 StackView
    private let containerStackView = ContainerStackView().then {
        $0.alignment = .top
    }
    
    /// 영화 썸네일 UIImageView
    private let thumbnailImageView = ThumbnailImageView(frame: .zero).then {
        $0.contentMode = .scaleAspectFit
    }
    
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView().then {
        $0.spacing = 5
    }
    
    /// 영화 제목 UILabel
    private let titleLabel = TitleLabel().then {
        $0.numberOfLines = 2
    }
    
    /// 영화 개봉 연도, 장르 UILabel
    private let yearGenreLabel = SubtitleLabel()
    
    /// 영화 설명 UILabel
    private let descriptionLabel = SubtitleLabel().then {
        $0.numberOfLines = 5
    }
    
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
    
    func configure(thumbnailImageURL: String, title: String, year: String, genre: String, description: String) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        // TODO: - 이미지 로드될때 애니메이션 추가
        Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailImageURL)
                self?.thumbnailImageView.image = UIImage(data: imageData)
            } catch {
                os_log(.error, log: log, "\(error.localizedDescription)")
            }
        }
        
        titleLabel.text = title
        yearGenreLabel.text = "\(year)년 • \(genre)"
        descriptionLabel.text = description
    }
}

// MARK: - UI Methods

private extension MovieCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(containerStackView, labelStackView)
        
        containerStackView.addArrangedSubviews(thumbnailImageView, labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           yearGenreLabel,
                                           descriptionLabel)
    }
    
    func setConstraints() {
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.height.equalTo(150)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.equalTo(100)
        }
    }
}
