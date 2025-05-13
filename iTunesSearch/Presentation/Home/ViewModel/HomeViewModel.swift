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

/// 홈 화면 ViewModel
final class HomeViewModel {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    //    private let apiiTunesSearchUseCase: APIiTunesSearchUseCase
    private let apiiTunesSearchUseCase = APIiTunesSearchManager()
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    // top5, summer, fall, winter
    typealias MusicListChunks = ([MusicResultModel], [MusicResultModel], [MusicResultModel], [MusicResultModel])
    struct Output {
        let musicListChunksRelay: PublishRelay<MusicListChunks>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let musicListChunksRelay = PublishRelay<MusicListChunks>()
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                // TODO: Repository 구현할 때 삭제해야 함
                let top5MusicRequestDTO = MusicRequestDTO(term: .spring, limit: 5)
                let summerMusicRequestDTO = MusicRequestDTO(term: .summer, limit: 15)
                let fallMusicRequestDTO = MusicRequestDTO(term: .fall, limit: 15)
                let winterMusicRequestDTO = MusicRequestDTO(term: .winter, limit: 15)
                
                return Observable.zip(owner.apiiTunesSearchUseCase.fetchMusicList(with: top5MusicRequestDTO).asObservable(),
                                      owner.apiiTunesSearchUseCase.fetchMusicList(with: summerMusicRequestDTO).asObservable(),
                                      owner.apiiTunesSearchUseCase.fetchMusicList(with: fallMusicRequestDTO).asObservable(),
                                      owner.apiiTunesSearchUseCase.fetchMusicList(with: winterMusicRequestDTO).asObservable())
            }.subscribe(with: self) { owner, element in
                musicListChunksRelay.accept(element)
            } onError: { owner, error in
                // TODO: - 에러 Alert 표시
                os_log(.error, log: owner.log, "\(error.localizedDescription)")
            }.disposed(by: disposeBag)
        
        return Output(musicListChunksRelay: musicListChunksRelay)
    }
    
    
    // MARK: - Initializer
    
    //    init(apiiTunesSearchUseCase: APIiTunesSearchUseCase) {
    //        self.apiiTunesSearchUseCase = apiiTunesSearchUseCase
    //    }
}
