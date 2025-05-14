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
    
    private let iTunesSearchAPIUseCase: iTunesSearchAPIUseCase
    
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
                let top5RequestDTO = iTunesQuery(term: MusicTerm.spring.rawValue, mediaType: .music, limit: 5)
                let summerRequestDTO = iTunesQuery(term: MusicTerm.summer.rawValue, mediaType: .music, limit: 15)
                let fallRequestDTO = iTunesQuery(term: MusicTerm.fall.rawValue, mediaType: .music, limit: 15)
                let winterRequestDTO = iTunesQuery(term: MusicTerm.winter.rawValue, mediaType: .music, limit: 15)
                
                async let top5MusicList = self.iTunesSearchAPIUseCase.fetchSearchResultList(with: top5RequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                async let summerMusicList = self.iTunesSearchAPIUseCase.fetchSearchResultList(with: summerRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                async let fallMusicList = self.iTunesSearchAPIUseCase.fetchSearchResultList(with: fallRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                async let winterMusicList = self.iTunesSearchAPIUseCase.fetchSearchResultList(with: winterRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                
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
}
