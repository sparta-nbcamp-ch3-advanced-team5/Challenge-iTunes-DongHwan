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
        
        Task { [weak self] in
            for try await _ in input.viewDidLoad.values {
                guard let self else { return }
                // TODO: Repository 구현할 때 삭제해야 함
                let top5MusicRequestDTO = MusicRequestDTO(term: .spring, limit: 5)
                let summerMusicRequestDTO = MusicRequestDTO(term: .summer, limit: 15)
                let fallMusicRequestDTO = MusicRequestDTO(term: .fall, limit: 15)
                let winterMusicRequestDTO = MusicRequestDTO(term: .winter, limit: 15)
                
                let musicDataZip = Observable.zip(self.apiiTunesSearchUseCase.rxFetchMusicList(with: top5MusicRequestDTO).asObservable(),
                                                self.apiiTunesSearchUseCase.rxFetchMusicList(with: summerMusicRequestDTO).asObservable(),
                                                self.apiiTunesSearchUseCase.rxFetchMusicList(with: fallMusicRequestDTO).asObservable(),
                                                self.apiiTunesSearchUseCase.rxFetchMusicList(with: winterMusicRequestDTO).asObservable())
                do {
                    for try await value in musicDataZip.values {
                        musicListChunksRelay.accept(value)
                    }
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        return Output(musicListChunksRelay: musicListChunksRelay)
    }
    
    
    // MARK: - Initializer
    
    //    init(apiiTunesSearchUseCase: APIiTunesSearchUseCase) {
    //        self.apiiTunesSearchUseCase = apiiTunesSearchUseCase
    //    }
}
