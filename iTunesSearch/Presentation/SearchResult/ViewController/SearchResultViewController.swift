//
//  SearchResultViewController.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import UIKit

import RxRelay
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
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    /// 검색어
    private let searchTextRelay = PublishRelay<String>()
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchTask?.cancel()
        fetchTask = nil
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
        // Input ➡️ ViewModel
        let input = SearchResultViewModel.Input(searchText: searchTextRelay.asInfallible())
        
        // ViewModel ➡️ Output
        let output = searchResultViewModel.transform(input: input)
        
        fetchTask = Task { [weak self] in
            for await element in output.searchResultChunksRelay.asDriver(onErrorJustReturn: ([], [], [])).values {
                let (searchText, podcastList, movieList) = element
                self?.configureSnapshot(searchText: searchText,
                                        podcastList: podcastList,
                                        movieList: movieList,
                                        animatingDifferences: true)
            }
        }
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
                           title: item.trackName,
                           artist: item.artistName)
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
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<SearchResultHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { header, elementKind, indexPath in
            let headerTitle = HeaderMarketingPhrases.allCases[indexPath.section].rawValue
            header.configure(title: headerTitle)
        }
        
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
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header: SearchResultHeaderView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            return header
        }
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
        // TODO: - smallBanner와 collection에 데이터 분배 로직 추가
        snapshot.appendItems(movieList.map { SearchResultItem.movie($0) }, toSection: .smallBanner)
        snapshot.appendItems(movieList.map { SearchResultItem.movieCollection($0) }, toSection: .collection)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchTextRelay.accept(searchController.searchBar.text ?? "")
    }
}
