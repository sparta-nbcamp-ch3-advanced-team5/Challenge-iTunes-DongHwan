//
//  SearchResultView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import UIKit

import SnapKit
import Then

/// 검색 결과 화면 View
final class SearchResultView: UIView {
    
    // MARK: - Properties
    
    private let groupFractionalWidth: CGFloat = 0.92
    private let bannerGroupAbsoluteHeight: CGFloat = 440
    
    // MARK: - UI Components
    
    /// 검색 결과 CollectionView
    private lazy var searchResultCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    // MARK: - Getter
    
    /// 음악 CollectionView 반환
    var getSearchResultCollectionView: UICollectionView {
        return searchResultCollectionView
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

// MARK: - UI Methods

private extension SearchResultView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(searchResultCollectionView)
    }
    
    func setConstraints() {
        searchResultCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - CompositionalLayout Methods

private extension SearchResultView {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 40
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
            if sectionIndex == 0 {
                return self.createSearchTextSection()
            } else if (sectionIndex - 1) % 3 == 0 {
                return self.createLargeBannerSection()
            } else if (sectionIndex - 1) % 3 == 1 {
                return self.createSmallBannerSection()
            } else {
                return self.createCollectionSection()
            }
//            switch section {
//            case .searchText:
//                return self.createSearchTextSection()
//            case .largeBanner:
//                return self.createLargeBannerSection()
//            case .smallBanner:
//                return self.createSmallBannerSection()
//            case .collection:
//                return self.createCollectionSection()
//            }
        }, configuration: config)
        
        return layout
    }
    
    func createSearchTextSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = itemContentInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(90))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func createLargeBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = itemContentInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(bannerGroupAbsoluteHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func createSmallBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = itemContentInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(bannerGroupAbsoluteHeight / 3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func createCollectionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(bannerGroupAbsoluteHeight / 7))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = itemContentInsets
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                               heightDimension: .absolute(bannerGroupAbsoluteHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
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
