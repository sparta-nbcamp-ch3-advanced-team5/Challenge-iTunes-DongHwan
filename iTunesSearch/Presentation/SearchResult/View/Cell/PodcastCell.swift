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
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    /// 코너값 표현을 위한 컨테이너 `UIView`
    private let cornerRadiusView = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    /// 팟캐스트 썸네일 `UIImageView`
    private let thumbnailView = ThumbnailView(frame: .zero).then {
        $0.getimageView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        $0.getActivityIndicator.style = .large
    }
    /// 블러 효과 `UIView`
    private let gradientContainerView = GradientContainerView().then {
        $0.startPoint = .init(x: 0.0, y: 0.0)
        $0.endPoint = .init(x: 0.0, y: 0.7)
    }
    /// 팟캐스트 마케팅 문구 `UILabel`
    private let marketingPhrasesLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    /// `labelStackView`, `goToButton` 컨테이너 `UIStackView`
    private let containerStackView = ContainerStackView()
    /// `UILabel` 컨테이너 `UIStackView`
    private let labelStackView = LabelStackView()
    /// 팟캐스트 제목 `UILabel`
    private let titleLabel = TitleLabel()
    /// 팟캐스트 진행자 `UILabel`
    private let artistLabel = SubtitleLabel()
    /// 아이튠즈 링크 이동 `UIButton`
    private let goToButton = GoToButton()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 셀에 그림자 적용
        setViewCornerRadAndShadow(baseView: cornerRadiusView,
                                  cornerRad: 15,
                                  shadowOffset: CGSize(width: 0, height: 2),
                                  shadowRad: 15,
                                  shadowOpacity: 0.2)
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
        thumbnailView.prepareForReuse()
    }
    
    // MARK: - Methods
    
    func configure(thumbnailURL: String, marketingPhrases: String, title: String, artist: String) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        fetchTask = Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailURL)
                self?.thumbnailView.getActivityIndicator.stopAnimating()
                self?.thumbnailView.getimageView.image = UIImage(data: imageData)
                self?.thumbnailView.startFadeInAnimation()
            } catch {
                self?.thumbnailView.setPlaceholder()
                os_log(.error, log: log, "\(error.localizedDescription)")
            }
        }
        marketingPhrasesLabel.text = marketingPhrases
        titleLabel.text = title
        artistLabel.text = artist
    }
}

// MARK: - Setting Methods

private extension PodcastCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubview(cornerRadiusView)
        
        cornerRadiusView.addSubviews(thumbnailView,
                                     containerStackView)
        
        thumbnailView.addSubview(gradientContainerView)
        
        gradientContainerView.addSubview(marketingPhrasesLabel)
        
        containerStackView.addArrangedSubviews(labelStackView, goToButton)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           artistLabel)
    }
    
    func setConstraints() {
        cornerRadiusView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(thumbnailView.snp.width)
        }
        
        gradientContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(marketingPhrasesLabel.snp.height).multipliedBy(1.5).offset(35)
        }
        
        marketingPhrasesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.trailing.equalToSuperview().inset(45)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(thumbnailView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        goToButton.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(34)
        }
    }
}
