//
//  HomeViewModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

/// 홈 화면 ViewModel
final class HomeViewModel {
    
    // MARK: - Properties
    
    private let iTunesSearchAPIUseCase: iTunesSearchAPIUseCase
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Infallible<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    /// top5MusicList, summerMusicList, fallMusicList, winterMusicList
    typealias MusicListChunks = ([MusicResultModel], [MusicResultModel], [MusicResultModel], [MusicResultModel])
    struct Output {
        let musicListChunksRelay: BehaviorRelay<MusicListChunks>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        let musicListChunksRelay = BehaviorRelay<MusicListChunks>(value: ([], [], [], []))
        
        fetchTask = Task { [iTunesSearchAPIUseCase] in
            for await _ in input.viewDidLoad.values {
                let top5RequestDTO = iTunesQuery(term: MusicTerm.spring.rawValue, mediaType: MediaType.music.rawValue, limit: 5)
                let summerRequestDTO = iTunesQuery(term: MusicTerm.summer.rawValue, mediaType: MediaType.music.rawValue, limit: 15)
                let fallRequestDTO = iTunesQuery(term: MusicTerm.fall.rawValue, mediaType: MediaType.music.rawValue, limit: 15)
                let winterRequestDTO = iTunesQuery(term: MusicTerm.winter.rawValue, mediaType: MediaType.music.rawValue, limit: 15)

                async let top5MusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: top5RequestDTO,
                                                                                       dtoType: MusicResultDTO.self,
                                                                                       transform: { $0.toModel() })
                async let summerMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: summerRequestDTO,
                                                                                         dtoType: MusicResultDTO.self,
                                                                                         transform: { $0.toModel() })
                async let fallMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: fallRequestDTO,
                                                                                       dtoType: MusicResultDTO.self,
                                                                                       transform: { $0.toModel() })
                async let winterMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: winterRequestDTO,
                                                                                         dtoType: MusicResultDTO.self,
                                                                                         transform: { $0.toModel() })

                do {
                    let musicListchunks = try await (top5MusicList, summerMusicList, fallMusicList, winterMusicList)
                    musicListChunksRelay.accept(musicListchunks)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        return Output(musicListChunksRelay: musicListChunksRelay)
    }
    
    // MARK: - Initializer
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
    
    deinit {
        // 네트워크 작업 취소
        fetchTask?.cancel()
    }
}
