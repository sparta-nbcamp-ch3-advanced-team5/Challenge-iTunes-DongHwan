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
    
    // Diffable DataSource
    typealias SearchResultDataSource = UICollectionViewDiffableDataSource<SearchResultSection, SearchResultItem>
    typealias SearchResultSnapshot = NSDiffableDataSourceSnapshot<SearchResultSection, SearchResultItem>
    private var dataSource: SearchResultDataSource!
    private var snapshot = SearchResultSnapshot()
    
    private var largeBannerPage = 0
    private var listPage = 0

    private var searchText = "" {
        didSet {
            configureSearchTextSnapshot(searchText: [searchText])
            searchTextRelay.accept(searchText)
        }
    }
    /// 검색어 Relay
    private let searchTextRelay = PublishRelay<String>()
    /// 맨 아래 스크롤 이벤트 Relay
    private let didScrolledBottom = PublishRelay<Void>()
    
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
        let input = SearchResultViewModel.Input(searchText: searchTextRelay.asInfallible(),
                                                didScrolledBottom: didScrolledBottom.asInfallible())
        
        // ViewModel ➡️ Output
        let output = searchResultViewModel.transform(input: input)
        
        Task {
            for await element in output.searchResultChunksRelay.asDriver(onErrorJustReturn: ([], [])).values {
                let (podcastList, movieList) = element
                self.configureResultsSnapshot(podcastList: podcastList,
                                              movieList: movieList,
                                              animatingDifferences: false)
                
                let collectionView = searchResultView.getSearchResultCollectionView
                let lastSection = collectionView.numberOfSections - 1
                let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
                
                if let loadingCell = collectionView.cellForItem(at: IndexPath(item: lastItem, section: lastSection)) as? LoadingCell {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    loadingCell.getActivityIndicator.stopAnimating()
                }
            }
        }
        
        // View ➡️ ViewController
        // 맨 아래 LoadingCell 표시할 때
        Task {
            for await (cell, _) in searchResultView.getSearchResultCollectionView.rx.willDisplayCell.asInfallible().values {
                if let loadingCell = cell as? LoadingCell, !loadingCell.getActivityIndicator.isAnimating {
                    // 데이터 추가적으로 로드
                    print("loading Data")
                    didScrolledBottom.accept(())
                    loadingCell.getActivityIndicator.startAnimating()
                }
            }
        }
        
        // 스크롤할 때
        Task {
            for await _ in searchResultView.getSearchResultCollectionView.rx.willBeginDragging.asInfallible().values {
                // 키보드 내림
                delegate?.willBeginDragging()
            }
        }
        
        // 셀 터치했을 때
        Task {
            for await indexPath in searchResultView.getSearchResultCollectionView.rx.itemSelected.asInfallible().values {
                dump(indexPath)
                // SearchTextCell인 경우
                if indexPath.section == 0 {
                    // 홈 화면으로 돌아감
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
        let searchTextCellRegistration = UICollectionView.CellRegistration<SearchTextCell, String> { cell, indexPath, _ in
            cell.configure(searchText: self.searchText)
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
        
        let loadingCellRegistration = UICollectionView.CellRegistration<LoadingCell, Void> { cell, indexPath, _ in
            cell.getActivityIndicator.stopAnimating()
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<ListSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { header, elementKind, indexPath in
            let index = indexPath.section % (HeaderMarketingPhrases.allCases.count - 1)
            let headerTitle = HeaderMarketingPhrases.allCases[index].rawValue
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
            case .loading:
                return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration,
                                                                    for: indexPath,
                                                                    item: ())
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    func configureSearchTextSnapshot(searchText: [String]) {
        snapshot.deleteAllItems()
        largeBannerPage = 0
        listPage = 0
        
        snapshot.appendSections([.searchText])
        snapshot.appendItems(searchText.map { SearchResultItem.searchText($0) }, toSection: .searchText)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    /// Diffable DataSource Snapshot 설정
    func configureResultsSnapshot(podcastList: [PodcastResultModel],
                                  movieList: [MovieResultModel],
                                  animatingDifferences: Bool) {
        
        configureSearchTextSnapshot(searchText: [searchText])
        
        if !podcastList.isEmpty {
            snapshot.appendSections([.largeBanner(page: largeBannerPage)])
            snapshot.appendItems(podcastList.map { SearchResultItem.podcast($0) }, toSection: .largeBanner(page: largeBannerPage))
            largeBannerPage += 1
        }
        if !movieList.isEmpty {
            snapshot.appendSections([.list(page: listPage)])
            snapshot.appendItems(movieList.map { SearchResultItem.movieList($0) }, toSection: .list(page: listPage))
            listPage += 1
        }
        
        snapshot.appendSections([.loading])
        snapshot.appendItems([SearchResultItem.loading], toSection: .loading)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchText = searchController.searchBar.text ?? ""
        let collectionView = searchResultView.getSearchResultCollectionView
        // Section 생성 확인 후 이동하지 않으면 Crash 발생
        if collectionView.numberOfSections > 0 {
            collectionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
        }
    }
}
