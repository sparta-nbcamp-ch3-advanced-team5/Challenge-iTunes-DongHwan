//
//  SeasonMusicCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit
import OSLog

import RxSwift
import SnapKit
import Then

/// 홈 화면 CollectionView 여름, 가을, 겨울 셀
final class SeasonMusicCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    // MARK: - UI Componenets
    
    /// 썸네일, LabelStackView 컨테이너 StackView
    private let containerStackView = ContainerStackView().then {
        $0.alignment = .center
    }
    
    /// 앨범 썸네일 UIImageView
    private let thumbnailImageView = ThumbnailImageView(frame: .zero)
    
    /// Label 컨테이너 StackView
    private let labelStackView = LabelStackView()
    
    /// 노래 제목 UILabel
    private let titleLabel = TitleLabel()
    
    /// 가수 이름 UILabel
    private let artistLabel = TitleLabel().then {
        $0.font = .systemFont(ofSize: 17)
    }
    
    /// 앨범 이름 UILabel
    private let collectionLabel = SubtitleLabel()
    
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
    
    func configure(thumbnailImageURL: String, title: String, artist: String, collection: String, isBottom: Bool) {
        // TODO: - 이미지 로드될때 애니메이션 추가
        Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailImageURL)
                self?.thumbnailImageView.image = UIImage(data: imageData)
            } catch {
                guard let self else { return }
                os_log(.error, log: self.log, "\(error.localizedDescription)")
            }
        }
        
        titleLabel.text = title
        artistLabel.text = artist
        collectionLabel.text = collection
        separatorView.isHidden = isBottom
    }
}

// MARK: - UI Methods

private extension SeasonMusicCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubviews(containerStackView,
                         separatorView)
        
        containerStackView.addArrangedSubviews(thumbnailImageView, labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           artistLabel,
                                           collectionLabel)
    }
    
    func setConstraints() {
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        
        labelStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }
        
//        titleLabel.snp.makeConstraints {
//            $0.leading.equalTo(artistLabel)
//            $0.trailing.equalToSuperview().inset(15)
//            $0.bottom.equalTo(artistLabel.snp.top).offset(-2)
//        }
//        
//        artistLabel.snp.makeConstraints {
//            $0.centerY.equalTo(thumbnailImageView).offset(2)
//            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(15)
//            $0.trailing.equalToSuperview().inset(15)
//        }
//        
//        collectionLabel.snp.makeConstraints {
//            $0.top.equalTo(artistLabel.snp.bottom).offset(2)
//            $0.leading.equalTo(artistLabel)
//            $0.trailing.equalToSuperview().inset(15)
//        }
        
        separatorView.snp.makeConstraints {
            $0.leading.equalTo(artistLabel)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}
