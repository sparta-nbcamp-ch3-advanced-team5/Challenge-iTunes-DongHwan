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

/// 음악 CollectionView 여름, 가을, 겨울 Cell
final class SeasonMusicCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Componenets
    
    /// 썸네일, LabelStackView 컨테이너 UIStackView
    private let containerStackView = ContainerStackView()
    
    /// 앨범 썸네일 UIImageView
    private let thumbnailView = ThumbnailView(frame: .zero)
    
    /// Label 컨테이너 UIStackView
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
    
    func configure(thumbnailURL: String, title: String, artist: String, collection: String, isBottom: Bool) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        fetchTask = Task { [weak self] in
            do {
                let imageData = try await ImageCacheManager.shared.fetchImage(from: thumbnailURL)
                self?.thumbnailView.getActivityIndicator.stopAnimating()
                self?.thumbnailView.getThumbnailImageView.image = UIImage(data: imageData)
                self?.thumbnailView.startFadeInAnimation()
            } catch {
                os_log(.error, log: log, "\(error.localizedDescription)")
            }
        }
        
        titleLabel.text = title
        artistLabel.text = artist
        collectionLabel.text = collection
        separatorView.isHidden = isBottom
    }
}

// MARK: - Setting Methods

private extension SeasonMusicCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(containerStackView,
                                     separatorView)
        
        containerStackView.addArrangedSubviews(thumbnailView, labelStackView)
        
        labelStackView.addArrangedSubviews(titleLabel,
                                           artistLabel,
                                           collectionLabel)
    }
    
    func setConstraints() {
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailView.snp.makeConstraints {
            $0.width.height.equalTo(64)
        }
        
        separatorView.snp.makeConstraints {
            $0.leading.equalTo(artistLabel)
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}
