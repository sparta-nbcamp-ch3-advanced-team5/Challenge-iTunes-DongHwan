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
    
    // MARK: - Properties
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    
    /// 팟캐스트 썸네일 UIImageView
    private let thumbnailImageView = ThumbnailImageView(frame: .zero).then {
        $0.activityIndicator.style = .large
    }
    /// 팟캐스트 마케팅 문구 UILabel
    private let marketingPhrasesLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }
    /// LabelStackView, Button 컨테이너 UIStackView
    private let containerStackView = ContainerStackView()
    /// Label 컨테이너 UIStackView
    private let labelStackView = LabelStackView()
    /// 팟캐스트 제목 UILabel
    private let titleLabel = TitleLabel()
    /// 팟캐스트 진행자 UILabel
    private let artistLabel = SubtitleLabel()
    /// 아이튠즈 링크 이동 버튼
    private let goToButton = GoToButton()
    
    // TODO: - 아이튠즈 연결 버튼 추가
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fetchTask?.cancel()
        fetchTask = nil
        thumbnailImageView.image = nil
        thumbnailImageView.activityIndicator.startAnimating()
    }
    
    // MARK: - Methods
    
    func configure(thumbnailImageURL: String, marketingPhrases: String, title: String, artist: String) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        // TODO: - 이미지 로드될때 애니메이션 추가
        fetchTask = Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailImageURL)
                self?.thumbnailImageView.activityIndicator.stopAnimating()
                self?.thumbnailImageView.image = UIImage(data: imageData)
            } catch {
                os_log(.error, log: log, "\(error.localizedDescription)")
            }
        }
        marketingPhrasesLabel.text = marketingPhrases
        titleLabel.text = title
        artistLabel.text = artist
    }
}

// MARK: - UI Methods

private extension PodcastCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(thumbnailImageView,
                                     marketingPhrasesLabel,
                                     containerStackView)
        
        containerStackView.addArrangedSubviews(labelStackView, goToButton)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           artistLabel)
    }
    
    func setConstraints() {
        thumbnailImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(thumbnailImageView.snp.width)
        }
        
        marketingPhrasesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.trailing.equalToSuperview().inset(45)
            $0.bottom.equalTo(thumbnailImageView).offset(-15)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        goToButton.snp.makeConstraints {
            $0.width.equalTo(72)
        }
    }
}
