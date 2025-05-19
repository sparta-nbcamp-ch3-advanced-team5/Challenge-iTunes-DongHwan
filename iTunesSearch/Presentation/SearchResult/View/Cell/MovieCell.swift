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
    
    // MARK: - Properties
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    
    /// 썸네일, `labelStackView` 컨테이너 `UIStackView`
    private let containerStackView = ContainerStackView().then {
        $0.alignment = .top
    }
    /// 영화 썸네일 `UIImageView`
    private let thumbnailView = ThumbnailView(frame: .zero).then {
        $0.contentMode = .scaleAspectFit
    }
    /// `UILabel` 컨테이너 `UIStackView`
    private let labelStackView = LabelStackView().then {
        $0.spacing = 5
    }
    /// 영화 제목 `UILabel`
    private let titleLabel = TitleLabel().then {
        $0.numberOfLines = 2
    }
    /// 영화 개봉 연도, 장르 `UILabel`
    private let yearGenreLabel = SubtitleLabel()
    /// 영화 설명 `UILabel`
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
    
    deinit {
        fetchTask?.cancel()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fetchTask?.cancel()
        thumbnailView.prepareForReuse()
    }
    
    // MARK: - Methods
    
    func configure(thumbnailURL: String, title: String, year: String, genre: String, description: String) {
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
        
        titleLabel.text = title
        yearGenreLabel.text = "\(year)년 • \(genre)"
        descriptionLabel.text = description
    }
}

// MARK: - Setting Methods

private extension MovieCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubviews(thumbnailView, labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           yearGenreLabel,
                                           descriptionLabel)
    }
    
    func setConstraints() {
        containerStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        thumbnailView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(150)
        }
    }
}
