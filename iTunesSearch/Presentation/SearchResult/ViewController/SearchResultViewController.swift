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
    
    /// 검색어 Relay
    private let searchTextRelay = PublishRelay<String>()
    weak var delegate: SearchResultViewControllerDelegate?
    
    // MARK: - UI Components
    
    /// 검색 결과 화면 View
    private let searchResultView = SearchResultView()
    
    // MARK: - Getter
    
    var getSearchResultView: SearchResultView {
        return searchResultView
    }
    
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

// MARK: - Setting Methods

private extension SearchResultViewController {
    func setupUI() {
        setAppearance()
        setDelegates()
        setViewHierarchy()
        setConstraints()
    }
    
    func setDelegates() {
        searchResultView.getSearchResultCollectionView.delegate = self
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
        let input = SearchResultViewModel.Input(searchText: searchTextRelay.asInfallible().distinctUntilChanged())
        
        // ViewModel ➡️ Output
        let output = searchResultViewModel.transform(input: input)
        
        Task {
            for await searchText in output.searchTextModelRelay.asDriver().values {
                self.configureSearchTextSnapshot(searchText: searchText)

//                if snapshot.itemIdentifiers(inSection: .searchText).isEmpty {
//                    self.configureSearchTextSnapshot(searchText: searchText)
//                } else {
//                    self.updateSearchTextSnapshot(searchText: searchText)
//                }
            }
        }
        
        Task {
            for await element in output.searchResultChunksRelay.asDriver(onErrorJustReturn: ([], [])).values {
                let (podcastList, movieList) = element
                self.configureResultsSnapshot(podcastList: podcastList,
                                              movieList: movieList)
            }
        }
        
        // View ➡️ ViewController
        Task {
            for await indexPath in searchResultView.getSearchResultCollectionView.rx.itemSelected.asInfallible().values {
                debugPrint(indexPath)
                if indexPath.section == 0 {
                    delegate?.searchTextCellTapped()
                }
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
            cell.configure(thumbnailURL: item.artworkUrl600,
                           marketingPhrases: item.marketingPhrase,
                           title: item.trackName,
                           artist: item.artistName)
        }
        
        let movieCellRegistration = UICollectionView.CellRegistration<MovieCell, MovieResultModel> { cell, indexPath, item in
            let year = DateFormatter.getYearFromISO(from: item.releaseDate)
            cell.configure(thumbnailURL: item.artworkUrl100,
                           title: item.trackName,
                           year: year,
                           genre: item.primaryGenreName,
                           description: item.longDescription)
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
            case .movieList(let movie):
                return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration,
                                                                    for: indexPath,
                                                                    item: movie)
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header: SearchResultHeaderView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            return header
        }
        
        snapshot.appendSections(SearchResultSection.allCases)
    }
    
    func configureSearchTextSnapshot(searchText: [SearchTextModel]) {
        let oldItems = snapshot.itemIdentifiers(inSection: .searchText)
        snapshot.deleteItems(oldItems)
        snapshot.appendItems(searchText.map { SearchResultItem.searchText($0) }, toSection: .searchText)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    /// Diffable DataSource Snapshot 설정
    func configureResultsSnapshot(podcastList: [PodcastResultModel],
                                  movieList: [MovieResultModel]) {
        snapshot.deleteSections([.largeBanner, .list])
        if !podcastList.isEmpty {
            snapshot.appendSections([.largeBanner])
            snapshot.appendItems(podcastList.map { SearchResultItem.podcast($0) }, toSection: .largeBanner)
        }
        if !movieList.isEmpty {
            snapshot.appendSections([.list])
            snapshot.appendItems(movieList.map { SearchResultItem.movieList($0) }, toSection: .list)
        }
        
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    func updateSearchTextSnapshot(searchText: [SearchTextModel]) {
        snapshot.reconfigureItems(searchText.map { SearchResultItem.searchText($0) })
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextRelay.accept(searchText)
        // Section 생성 확인 후 이동하지 않으면 Crash 발생
        if searchResultView.getSearchResultCollectionView.numberOfSections > 0 {
            searchResultView.getSearchResultCollectionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchResultViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.willBeginDragging()
    }
}
