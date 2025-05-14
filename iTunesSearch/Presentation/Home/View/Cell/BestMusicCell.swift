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

/// 홈 화면 CollectionView 봄 Best 셀
final class BestMusicCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    // MARK: - UI Components
    
    /// 가수 사진 UIImageView(API에 가수 사진이 없으므로 배경색만 변경)
    private let artistImageView = BackgroundImageView(frame: .zero).then {
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
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(thumbnailImageURL: String, artistImageColor: UIColor, title: String, artist: String) {
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
        
        artistImageView.backgroundColor = artistImageColor
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
        self.addSubviews(artistImageView, containerStackView)
        
        containerStackView.addArrangedSubviews(thumbnailImageView, labelStackView)
        
        labelStackView.addArrangedSubviews(topSpacer,
                                           titleLabel,
                                           artistLabel)
    }
    
    func setConstraints() {
        artistImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(15)
            $0.height.equalTo(44)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        topSpacer.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        labelStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
        }
    }
}
