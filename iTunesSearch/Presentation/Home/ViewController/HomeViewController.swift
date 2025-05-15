//
//  HomeViewController.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import RxSwift
import RxCocoa
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
    
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    
    /// 홈 화면 네비게이션 바 SearchController
    private let searchController = UISearchController(searchResultsController: SearchResultViewController(searchResultViewModel: SearchResultViewModel()))
    
    /// 홈 화면 View
    private let homeView = HomeView()
    
    // MARK: - Initializer
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
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
        
        fetchTask = Task { [weak self] in
            for await element in output.musicListChunksRelay.asDriver(onErrorJustReturn: ([], [], [], [])).values {
                guard let self else { return }
                let (top5MusicList, summerMusicList, fallMusicList, winterMusicList) = element
                self.configureSnapshot(top5MusicList: top5MusicList,
                                        summerMusicList: summerMusicList,
                                        fallMusicList: fallMusicList,
                                        winterMusicList: winterMusicList,
                                        animatingDifferences: true)
            }
        }
    }
}

// MARK: - DataSource Methods

private extension HomeViewController {
    /// Diffable DataSource 설정
    func configureDataSource() {
        let bestCellRegistration = UICollectionView.CellRegistration<BestMusicCell, MusicResultModel> { cell, indexPath, item in
            let artistImageColor = UIColor.artistImageColors[item.artistImageColorIndex]
            cell.configure(thumbnailImageURL: item.artworkUrl100,
                           artistImageColor: artistImageColor,
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
    }
    
    /// Diffable DataSource Snapshot 설정
    func configureSnapshot(top5MusicList: [MusicResultModel],
                           summerMusicList: [MusicResultModel],
                           fallMusicList: [MusicResultModel],
                           winterMusicList: [MusicResultModel],
                           animatingDifferences: Bool) {
        snapshot.deleteAllItems()
        snapshot.appendSections(HomeSection.allCases)
        
        snapshot.appendItems(top5MusicList.map { HomeItem.best($0) }, toSection: .springBest)
        snapshot.appendItems(summerMusicList.map { HomeItem.season($0) }, toSection: .summer)
        snapshot.appendItems(fallMusicList.map { HomeItem.season($0) }, toSection: .fall)
        snapshot.appendItems(winterMusicList.map { HomeItem.season($0) }, toSection: .winter)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
