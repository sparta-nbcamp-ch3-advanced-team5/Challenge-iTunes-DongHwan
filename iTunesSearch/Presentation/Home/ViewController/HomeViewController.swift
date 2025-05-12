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
    
    private let homeViewModel = HomeViewModel()
//    private let viewModel: HomeViewModel
    
    private let disposeBag = DisposeBag()
    
//    typealias Item =
//    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
//    enum Section {
//        case main
//    }
    
    // MARK: - UI Components
    
    private let homeView = HomeView()
    
    // MARK: - Initializer
    
//    init(viewModel: HomeViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        bind()
    }
}

// MARK: - UI Methods

private extension HomeViewController {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
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
        let input = HomeViewModel.Input(viewDidLoad: Observable.just(()))
        
        // ViewModel ➡️ Output
        let output = homeViewModel.transform(input: input)
        
        output.top5MusicData
            .subscribe { response in
                print(response)
            }.disposed(by: disposeBag)
    }
}
