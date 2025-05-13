//
//  HomeViewController.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var homeViewModel: ViewModelable
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    // 홈 화면 View
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
        self.navigationController?.navigationBar.topItem?.title = "Music"
        self.navigationController?.navigationBar.prefersLargeTitles = true
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
        // ViewModel ➡️ State
        
        // Action ➡️ ViewModel
        // viewDidLoad 알림
        homeViewModel.action.onNext(.viewDidLoad)
    }
}

// MARK: - UICollectionView Methods

private extension HomeViewController {
    /// DiffableDataSource 설정
    func configureDataSource() {
        let bestCellRegistration = UICollectionView.CellRegistration<BestCell, MusicResultModel> { cell, indexPath, item in
            // TODO: thumbnailImage 수정
            cell.configure(artistImageColorIndex: item.artistImageColorIndex,
                           thumbnailImage: UIImage(),
                           title: item.trackName,
                           artist: item.artistName)
        }
        
        let seasonCellRegistration = UICollectionView.CellRegistration<SeasonCell, MusicResultModel> { cell, indexPath, item in
            // TODO: thumbnailImage 수정
            cell.configure(thumbnailImage: UIImage(),
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
        
        homeViewModel.dataSource = DataSource(collectionView: homeView.getCollectionView, cellProvider: { collectionView, indexPath, itemList in
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
        
        homeViewModel.dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header: HomeHeaderView = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            return header
        }
    }
}
