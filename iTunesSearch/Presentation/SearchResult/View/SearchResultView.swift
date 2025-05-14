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
    
    // MARK: - UI Components
    
    /// 검색 결과 화면 CollectionView
//    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
}

// MARK: - CompositionalLayout Methods

private extension SearchResultView {
//    func createLayout() -> UICollectionViewCompositionalLayout {
//        let config = UICollectionViewCompositionalLayoutConfiguration()
//        config.interSectionSpacing = 20
//        
//        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
//            guard let self , let section = HomeSection(rawValue: sectionIndex) else { return nil }
//            switch section {
//            case .springBest:
//                return self.createCarouselBannerSection()
//            default:
//                return self.createThreeRowPagingSection()
//            }
//        }, configuration: config)
//        
//        return layout
//    }
//    
//    func createCarouselBannerSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
////        item.contentInsets = itemContentInsets
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
//                                               heightDimension: .absolute(240))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
////        section.orthogonalScrollingBehavior = .groupPagingCentered
//        
//        let headerView = createHeader()
//        section.boundarySupplementaryItems = [headerView]
//        
//        return section
//    }
//    
//    func createThreeRowPagingSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .fractionalHeight(0.33))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = itemContentInsets
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
//                                               heightDimension: .absolute(270))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .groupPagingCentered
//        
//        let headerView = createHeader()
//        section.boundarySupplementaryItems = [headerView]
//        
//        return section
//    }
//    
//    
//    func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth), heightDimension: .absolute(60))
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
//                                                                            elementKind: UICollectionView.elementKindSectionHeader,
//                                                                            alignment: .top)
//        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
//        
//        return sectionHeader
//    }
}
