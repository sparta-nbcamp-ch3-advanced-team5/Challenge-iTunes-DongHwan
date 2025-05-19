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
    
    private var searchText = "" {
        didSet {
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
            for await element in output.searchResultChunksRelay.asDriver(onErrorJustReturn: ([], [], [])).values {
                let (searchText, podcastList, movieList) = element
                self.configureSnapshot(searchText: searchText,
                                       podcastList: podcastList,
                                       movieList: movieList,
                                       animatingDifferences: true)
                
                let collectionView = searchResultView.getSearchResultCollectionView
                let lastSection = collectionView.numberOfSections - 1
                let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
                if let loadingCell = collectionView.cellForItem(at: IndexPath(item: lastItem, section: lastSection)) as? LoadingCell {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    loadingCell.getActivityIndicator.stopAnimating()
                    print("activityIndicator stop")
                }
            }
        }
        
        // View ➡️ ViewController
        // 맨 아래 LoadingCell 표시할 때
        Task {
            for await (cell, _) in searchResultView.getSearchResultCollectionView.rx.willDisplayCell.asInfallible().values {
                if let loadingCell = cell as? LoadingCell, !searchText.isEmpty && !loadingCell.getActivityIndicator.isAnimating {
                    // 데이터 추가적으로 로드
                    didScrolledBottom.accept(())
                    loadingCell.getActivityIndicator.startAnimating()
                    print("activityIndicator start")
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
                debugPrint(indexPath)
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
    
    func configureSnapshot(searchText: [SearchTextModel],
                           podcastList: [PodcastResultModel],
                           movieList: [MovieResultModel],
                           animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        
        snapshot.appendSections([.searchText])
        snapshot.appendItems(searchText.map { SearchResultItem.searchText($0) }, toSection: .searchText)
        if !podcastList.isEmpty {
            snapshot.appendSections([.largeBanner])
            snapshot.appendItems(podcastList.map { SearchResultItem.podcast($0) }, toSection: .largeBanner)
        }
        if !movieList.isEmpty {
            snapshot.appendSections([.list])
            snapshot.appendItems(movieList.map { SearchResultItem.movieList($0) }, toSection: .list)
        }
        snapshot.appendSections([.loading])
        snapshot.appendItems([SearchResultItem.loading], toSection: .loading)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        let collectionView = searchResultView.getSearchResultCollectionView
        // Section 생성 확인 후 이동하지 않으면 Crash 발생
        if collectionView.numberOfSections > 0 {
            collectionView.scrollToItem(at: IndexPath(item: -1, section: 0), at: .top, animated: false)
        }
    }
}
