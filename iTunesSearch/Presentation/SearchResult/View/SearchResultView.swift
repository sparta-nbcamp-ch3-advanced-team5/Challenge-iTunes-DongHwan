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
    
    private let topBottomInset: CGFloat
    private let leadingTrailingInset: CGFloat
    private let largeBannerItemHeight: CGFloat
    private let listItemHeight: CGFloat
    
    private let itemContentInset: NSDirectionalEdgeInsets
    private let headerContentInset: NSDirectionalEdgeInsets
    
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
        topBottomInset = 10
        leadingTrailingInset = 20
        itemContentInset = .init(top: topBottomInset,
                                 leading: leadingTrailingInset,
                                 bottom: topBottomInset,
                                 trailing: leadingTrailingInset)
        headerContentInset = .init(top: 0,
                                   leading: leadingTrailingInset,
                                   bottom: topBottomInset,
                                   trailing: leadingTrailingInset)
        largeBannerItemHeight = 440 + topBottomInset * 2
        listItemHeight = 150 + topBottomInset * 2
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Methods

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
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
            guard let section = SearchResultSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .searchText:
                return self.createSearchTextSection()
            case .largeBanner:
                return self.createLargeBannerSection()
            case .list:
                return self.createListSection()
            case .loading:
                return self.createLoadingSection()
            }
        }, configuration: config)
        
        layout.register(ListSectionBackgroundView.self, forDecorationViewOfKind: ListSectionBackgroundView.identifier)
        return layout
    }
    
    func createSearchTextSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 20, leading: leadingTrailingInset, bottom: 0, trailing: leadingTrailingInset)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func createLargeBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(1.11))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemContentInset
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(largeBannerItemHeight * 5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(listItemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemContentInset
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(largeBannerItemHeight * 10))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerView = createHeader()
        section.boundarySupplementaryItems = [headerView]
        
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: ListSectionBackgroundView.identifier)
        sectionBackgroundDecoration.contentInsets = .init(top: 0, leading: leadingTrailingInset, bottom: 0, trailing: leadingTrailingInset)
        section.decorationItems = [sectionBackgroundDecoration]
        
        return section
    }
    
    func createLoadingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemContentInset
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(64))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        sectionHeader.contentInsets = headerContentInset
        
        return sectionHeader
    }
}
