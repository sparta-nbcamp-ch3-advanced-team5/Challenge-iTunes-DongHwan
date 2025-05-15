//
//  HomeViewController.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

/// 홈 화면 ViewController
final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let homeViewModel: HomeViewModel
    
    // Diffable DataSource
    typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>
    typealias HomeSnapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>
    private var dataSource: HomeDataSource!
    private var snapshot = HomeSnapshot()
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: [Task<Void, Never>]?
    
    // MARK: - UI Components
    
    /// 홈 화면 네비게이션 바 SearchController
    private let searchController: UISearchController
    /// 검색 결과 ViewController
    private let searchResultViewController: SearchResultViewController
    /// 홈 화면 View
    private let homeView = HomeView()
    
    // MARK: - Initializer
    
    init(homeViewModel: HomeViewModel, searchResultViewController: SearchResultViewController) {
        self.homeViewModel = homeViewModel
        self.searchResultViewController = searchResultViewController
        searchController = UISearchController(searchResultsController: searchResultViewController)
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
        fetchTask?.forEach { $0.cancel() }
        fetchTask = nil
    }
}

// MARK: - UI Methods

private extension HomeViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "Music"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchBar.placeholder = "영화, 팟캐스트"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
    }
    
    func setViewHierarchy() {
        self.view.addSubview(homeView)
    }
    
    func setConstraints() {
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        // Input ➡️ ViewModel
        let input = HomeViewModel.Input(viewDidLoad: Infallible.just(()))
        
        // ViewModel ➡️ Output
        let output = homeViewModel.transform(input: input)
        
        let top5Task = Task { [weak self] in
            for await top5MusicList in output.top5MusicListRelay.asDriver().values {
                self?.updateSection(of: .springBest, with: top5MusicList, animatingDifferences: true)
            }
        }
        
        let summerTask = Task { [weak self] in
            for await summerMusicList in output.summerMusicListRelay.asDriver().values {
                self?.updateSection(of: .summer, with: summerMusicList, animatingDifferences: true)
            }
        }
        
        let fallTask = Task { [weak self] in
            for await fallMusicList in output.fallMusicListRelay.asDriver().values {
                self?.updateSection(of: .fall, with: fallMusicList, animatingDifferences: true)
            }
        }
        
        let winterTask = Task { [weak self] in
            for await winterMusicList in output.winterMusicListRelay.asDriver().values {
                self?.updateSection(of: .winter, with: winterMusicList, animatingDifferences: true)
            }
        }
        
        [top5Task, summerTask, fallTask, winterTask].forEach { fetchTask?.append($0) }
    }
}

// MARK: - DataSource Methods

private extension HomeViewController {
    /// Diffable DataSource 설정
    func configureDataSource() {
        let bestCellRegistration = UICollectionView.CellRegistration<BestMusicCell, MusicResultModel> { cell, indexPath, item in
            let color = UIColor(hex: item.backgroundArtistImageColorHex)
            cell.configure(thumbnailImageURL: item.artworkUrl100,
                           backgroundArtistImageColor: color,
                           title: item.trackName,
                           artist: item.artistName)
        }
        
        let seasonCellRegistration = UICollectionView.CellRegistration<SeasonMusicCell, MusicResultModel> { cell, indexPath, item in
            cell.configure(thumbnailImageURL: item.artworkUrl100,
                           title: item.trackName,
                           artist: item.artistName,
                           collection: item.collectionName ?? "",
                           isBottom: (indexPath.item + 1) % 3 == 0)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HomeHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { header, elementKind, indexPath in
            let headerTitle = HomeSection.allCases[indexPath.section].title
            let headerSubtitle = HomeSection.allCases[indexPath.section].subtitle
            header.configure(title: headerTitle, subtitle: headerSubtitle)
        }
        
        dataSource = HomeDataSource(collectionView: homeView.getMusicCollectionView, cellProvider: { collectionView, indexPath, itemList in
            switch itemList {
            case .best(let top5Music):
                let cell = collectionView.dequeueConfiguredReusableCell(using: bestCellRegistration,
                                                                        for: indexPath,
                                                                        item: top5Music)
                return cell
            case .season(let music):
                let cell = collectionView.dequeueConfiguredReusableCell(using: seasonCellRegistration,
                                                                        for: indexPath,
                                                                        item: music)
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header: HomeHeaderView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            return header
        }
        
        configureSnapshot()
    }
    
    /// Diffable DataSource Snapshot 설정
    func configureSnapshot() {
        snapshot.deleteAllItems()
        snapshot.appendSections(HomeSection.allCases)
    }
    
    func updateSection(of section: HomeSection, with musicList: [MusicResultModel], animatingDifferences: Bool) {
        let newItems: [HomeItem]
        switch section {
        case .springBest:
            newItems = musicList.map { HomeItem.best($0) }
        default:
            newItems = musicList.map { HomeItem.season($0) }
        }
        
        snapshot.appendItems(newItems, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}


extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
