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
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    
    /// 가수 사진 UIImageView(API에 가수 사진이 없으므로 배경색만 변경)
    private let backgroundArtistImageView = BackgroundImageView(frame: .zero).then {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        $0.image = UIImage(systemName: "music.note", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    /// 썸네일, LabelStackView 컨테이너 StackView
    private let containerStackView = ContainerStackView()
    
    /// 앨범 썸네일 UIImageView
    private let thumbnailImageView = ThumbnailImageView(frame: .zero)
    
    /// Label 컨테이너 StackView
    private let labelStackView = LabelStackView()
    
    /// LabelStackView가 위쪽 간격을 갖도록 하는 Spacer
    private let topSpacer = UIView.spacer(axis: .vertical)
    
    /// 노래 제목 UILabel
    private let titleLabel = TitleLabel()
    
    /// 가수 이름 UILabel
    private let artistLabel = SubtitleLabel()
    
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
        thumbnailImageView.image = nil
        thumbnailImageView.activityIndicator.startAnimating()
    }
    
    // MARK: - Methods
    
    func configure(thumbnailImageURL: String, backgroundArtistImageColor: UIColor, title: String, artist: String) {
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
        
        backgroundArtistImageView.backgroundColor = backgroundArtistImageColor
        titleLabel.text = title
        artistLabel.text = artist
    }
}

// MARK: - UI Methods

private extension BestMusicCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(backgroundArtistImageView, containerStackView)
        
        containerStackView.addArrangedSubviews(thumbnailImageView, labelStackView)
        
        labelStackView.addArrangedSubviews(topSpacer,
                                           titleLabel,
                                           artistLabel)
    }
    
    func setConstraints() {
        backgroundArtistImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(15)
            $0.height.equalTo(50)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        topSpacer.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }
}
