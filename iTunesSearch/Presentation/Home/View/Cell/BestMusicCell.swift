//
//  BestMusicCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit
import OSLog

import RxSwift
import SnapKit
import Then

/// 음악 CollectionView 봄 Best Cell
final class BestMusicCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    
    /// 가수 사진 `UIImageView`(API에 가수 사진이 없으므로 배경색만 변경)
    private let backgroundArtistImageView = BackgroundImageView(frame: .zero).then {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        $0.image = UIImage(systemName: "music.note", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        $0.contentMode = .center
    }
    /// 블러 효과 `UIView`
    private let gradientContainerView = GradientContainerView().then {
        $0.startPoint = .init(x: 0.0, y: 0.0)
        $0.endPoint = .init(x: 0.0, y: 1.0)
    }
    /// 썸네일, `labelStackView` 컨테이너 `UIStackView`
    private let thumbnailLabelStackView = ContainerStackView()
    /// 앨범 썸네일 UIImageView
    private let thumbnailView = ThumbnailView(frame: .zero)
    /// `UILabel` 컨테이너 `UIStackView`
    private let labelStackView = LabelStackView()
    /// 노래 제목 `UILabel`
    private let titleLabel = TitleLabel().then {
        $0.textColor = .black
    }
    /// 가수 이름 `UILabel`
    private let artistLabel = SubtitleLabel().then {
        $0.textColor = .darkGray
    }
    
    // TODO: - 아이튠즈 연결 버튼 추가
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 셀에 그림자 적용
        setViewCornerRadAndShadow(baseView: backgroundArtistImageView,
                                  cornerRad: 15,
                                  shadowOffset: CGSize(width: 0, height: 10),
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
    
    func configure(thumbnailURL: String, backgroundArtistImageColor: UIColor, title: String, artist: String) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        fetchTask = Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailURL)
                self?.thumbnailView.getActivityIndicator.stopAnimating()
                self?.thumbnailView.getimageView.image = UIImage(data: imageData)
                self?.thumbnailView.startFadeInAnimation()
                
                self?.backgroundArtistImageView.image = UIImage(data: imageData)
                self?.backgroundArtistImageView.contentMode = .scaleAspectFill
            } catch {
                self?.thumbnailView.setPlaceholder()
                os_log(.error, log: log, "\(error.localizedDescription)")
            }
        }
        
        backgroundArtistImageView.backgroundColor = backgroundArtistImageColor
        titleLabel.text = title
        artistLabel.text = artist
    }
}

// MARK: - Setting Methods

private extension BestMusicCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubview(backgroundArtistImageView)
        
        backgroundArtistImageView.addSubview(gradientContainerView)
        
        gradientContainerView.addSubview(thumbnailLabelStackView)
        
        thumbnailLabelStackView.addArrangedSubviews(thumbnailView, labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           artistLabel)
    }
    
    func setConstraints() {
        backgroundArtistImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradientContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(thumbnailLabelStackView).offset(30)
        }
        
        thumbnailLabelStackView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
        thumbnailView.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
    }
}
