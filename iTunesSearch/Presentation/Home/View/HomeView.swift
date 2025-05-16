//
//  HomeView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import SnapKit
import Then

/// 홈 화면 View
final class HomeView: UIView {
    
    // MARK: - Properties
    
    private let groupFractionalWidth: CGFloat = 0.92
    
    // MARK: - UI Components
    
    /// 음악 CollectionView
    private lazy var musicCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    // MARK: - Getter
    
    /// 음악 CollectionView 반환
    var getMusicCollectionView: UICollectionView {
        return musicCollectionView
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Methods

private extension HomeView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(musicCollectionView)
    }
    
    func setConstraints() {
        musicCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - CompositionalLayout Methods

private extension HomeView {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
            guard let self, let section = HomeSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .springBest:
                return self.createCarouselBannerSection()
            default:
                return self.createThreeRowPagingSection()
            }
        }, configuration: config)
        
        return layout
    }
    
    func createCarouselBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.66))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(260))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        let headerView = createHeader()
        section.boundarySupplementaryItems = [headerView]
        
        return section
    }
    
    func createThreeRowPagingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.33))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        let headerView = createHeader()
        section.boundarySupplementaryItems = [headerView]
        
        return section
    }
    
    func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth), heightDimension: .absolute(60))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        
        return sectionHeader
    }
}
