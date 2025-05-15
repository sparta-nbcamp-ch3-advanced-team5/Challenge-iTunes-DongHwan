//
//  SearchResultViewController.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import UIKit

import RxSwift
import SnapKit
import Then

/// 검색 결과 화면 ViewController
final class SearchResultViewController: UIViewController {
    
    // MARK: - Properties
    
    private let searchResultViewModel: SearchResultViewModel
    private let disposeBag = DisposeBag()
    
    // Diffable DataSource
    typealias SearchResultDataSource = UICollectionViewDiffableDataSource<SearchResultSection, SearchResultItem>
    typealias SearchResultSnapshot = NSDiffableDataSourceSnapshot<SearchResultSection, SearchResultItem>
    private var dataSource: SearchResultDataSource!
    private var snapshot = SearchResultSnapshot()
    
    // MARK: - UI Components
    
    /// 검색 결과 화면 View
    private let searchResultView = SearchResultView()
    
    // MARK: - Initializer
    
    init(searchResultViewModel: SearchResultViewModel) {
        self.searchResultViewModel = searchResultViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureDataSource()
        bind()
    }
}

// MARK: - UI Methods

private extension SearchResultViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .systemBackground
    }
    
    func setViewHierarchy() {
        self.view.addSubview(searchResultView)
    }
    
    func setConstraints() {
        searchResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        
    }
}

// MARK: - DataSource Methods

private extension SearchResultViewController {
    /// Diffable DataSource 설정
    func configureDataSource() {
        let searchTextCellRegistration = UICollectionView.CellRegistration<SearchTextCell, SearchTextModel> { cell, indexPath, item in
            cell.configure(searchText: item.searchText)
        }
        
        let podCastCellRegistration = UICollectionView.CellRegistration<PodcastCell, PodcastResultModel> { cell, indexPath, item in
            cell.configure(thumbnailImageURL: item.artworkUrl600,
                           marketingPhrases: item.marketingPhrase,
                           title: item.trackName)
        }
        
        let movieCellRegistration = UICollectionView.CellRegistration<MovieCell, MovieResultModel> { cell, indexPath, item in
            let color = UIColor(hex: item.backgroundArtistImageColorHex)
            cell.configure(thumbnailImageURL:  item.artworkUrl100,
                           backgroundImageColor: color,
                           title: item.trackName,
                           genre: item.primaryGenreName)
        }
        
        let movieCollectionCellRegistration = UICollectionView.CellRegistration<MovieCollectionCell, MovieResultModel> { cell, indexPath, item in
            let year = DateFormatter.getYearFromISO(from: item.releaseDate)
            cell.configure(thumbnailImageURL: item.artworkUrl100,
                           title: item.trackName,
                           year: year,
                           genre: item.primaryGenreName)
        }
        
//        let headerRegistration = UICollectionView.SupplementaryRegistration<HomeHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { header, elementKind, indexPath in
//            let headerTitle = HomeSection.allCases[indexPath.section].title
//            let headerSubtitle = HomeSection.allCases[indexPath.section].subtitle
//            header.configure(title: headerTitle, subtitle: headerSubtitle)
//        }
        
        dataSource = SearchResultDataSource(collectionView: searchResultView.getSearchResultCollectionView, cellProvider: { collectionView, indexPath, itemList in
            switch itemList {
            case .searchText(let searchText):
                return collectionView.dequeueConfiguredReusableCell(using: searchTextCellRegistration,
                                                                    for: indexPath,
                                                                    item: searchText)
            case .podcast(let podcast):
                return collectionView.dequeueConfiguredReusableCell(using: podCastCellRegistration,
                                                                    for: indexPath,
                                                                    item: podcast)
            case .movie(let movie):
                return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration,
                                                                    for: indexPath,
                                                                    item: movie)
            case .movieCollection(let movie):
                return collectionView.dequeueConfiguredReusableCell(using: movieCollectionCellRegistration,
                                                                    for: indexPath,
                                                                    item: movie)
            }
            
        })
        
//        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
//            let header: HomeHeaderView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//            return header
//        }
    }
    
    /// Diffable DataSource Snapshot 설정
    func configureSnapshot(searchText: [SearchTextModel],
                           podcastList: [PodcastResultModel],
                           movieList: [MovieResultModel],
                           animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        snapshot.appendSections(SearchResultSection.allCases)
        
        snapshot.appendItems(searchText.map { SearchResultItem.searchText($0) }, toSection: .searchText)
        snapshot.appendItems(podcastList.map { SearchResultItem.podcast($0) }, toSection: .largeBanner)
        snapshot.appendItems(movieList.map { SearchResultItem.movie($0) }, toSection: .smallBanner)
        snapshot.appendItems(movieList.map { SearchResultItem.movieCollection($0) }, toSection: .collection)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
