//
//  HomeViewModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation
import OSLog

import RxSwift
import RxRelay

final class HomeViewModel: ViewModelable {

    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: HomeViewModel.self))
    private let disposeBag = DisposeBag()
    
//    private let apiiTunesSearchUseCase: APIiTunesSearchUseCase
    private let apiiTunesSearchUseCase = APIiTunesSearchManager()
    
    // Action (ViewController ➡️ ViewModel)
    var action: AnyObserver<Action> {
        state.actionSubject.asObserver()
    }

    // State (ViewModel ➡️ ViewController)
    var state = State()
    
    var dataSource: DataSource!
    private var snapshot = Snapshot()
    
    // MARK: - Initializer
    
//    init(apiiTunesSearchUseCase: APIiTunesSearchUseCase) {
//        self.apiiTunesSearchUseCase = apiiTunesSearchUseCase
//    }
    
    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchMusicList()
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - State Methods (ViewModel ➡️ ViewController)

private extension HomeViewModel {
    /// iTunes Search API로 Music 데이터 요청
    func fetchMusicList() {
        let top5MusicRequestDTO = MusicRequestDTO(term: .spring, limit: 5)
        let summerMusicRequestDTO = MusicRequestDTO(term: .summer, limit: 15)
        let fallMusicRequestDTO = MusicRequestDTO(term: .fall, limit: 15)
        let winterMusicRequestDTO = MusicRequestDTO(term: .winter, limit: 15)
        
        Observable.combineLatest(apiiTunesSearchUseCase.fetchMusicList(with: top5MusicRequestDTO).asObservable(),
                                 apiiTunesSearchUseCase.fetchMusicList(with: summerMusicRequestDTO).asObservable(),
                                 apiiTunesSearchUseCase.fetchMusicList(with: fallMusicRequestDTO).asObservable(),
                                 apiiTunesSearchUseCase.fetchMusicList(with: winterMusicRequestDTO).asObservable())
        .subscribe(with: self) { owner, element in
            let (top5MusicList, summerMusicList, fallMusicList, winterMusicList) = element
            owner.configureSnapshot(top5MusicList: top5MusicList,
                                      summerMusicList: summerMusicList,
                                      fallMusicList: fallMusicList,
                                      winterMusicList: winterMusicList,
                                      animatingDifferences: false)
        } onError: { owner, error in
            os_log(.error, log: owner.log, "\(error.localizedDescription)")
        }.disposed(by: disposeBag)
    }
}

// MARK: - Snapshot Methods

private extension HomeViewModel {
    /// DiffableDataSourceSnapshot 설정
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
