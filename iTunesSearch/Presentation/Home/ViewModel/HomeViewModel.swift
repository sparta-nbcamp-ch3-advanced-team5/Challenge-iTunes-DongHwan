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
                // TODO: Repository 구현할 때 삭제해야 함
                let top5RequestDTO = RequestDTO(term: MusicTerm.spring.rawValue, mediaType: .music, limit: 5)
                let summerRequestDTO = RequestDTO(term: MusicTerm.summer.rawValue, mediaType: .music, limit: 15)
                let fallRequestDTO = RequestDTO(term: MusicTerm.fall.rawValue, mediaType: .music, limit: 15)
                let winterRequestDTO = RequestDTO(term: MusicTerm.winter.rawValue, mediaType: .music, limit: 15)
                
                let top5RxSingle = self.iTunesSearchAPIUseCase.rxFetchSearchResultList(with: top5RequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                let summerRxSingle = self.iTunesSearchAPIUseCase.rxFetchSearchResultList(with: summerRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                let fallRxSingle = self.iTunesSearchAPIUseCase.rxFetchSearchResultList(with: fallRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                let winterRxSingle = self.iTunesSearchAPIUseCase.rxFetchSearchResultList(with: winterRequestDTO, dtoType: MusicResultDTO.self, transform: { $0.toModel() })
                
                let musicDataZip = Observable.zip(top5RxSingle.asObservable(), summerRxSingle.asObservable(), fallRxSingle.asObservable(), winterRxSingle.asObservable())
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
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
}
