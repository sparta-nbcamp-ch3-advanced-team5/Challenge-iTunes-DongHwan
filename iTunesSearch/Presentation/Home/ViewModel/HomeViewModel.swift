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
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: [Task<Void, Never>]?
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Infallible<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    struct Output {
        let top5MusicListRelay: BehaviorRelay<[MusicResultModel]>
        let summerMusicListRelay: BehaviorRelay<[MusicResultModel]>
        let fallMusicListRelay: BehaviorRelay<[MusicResultModel]>
        let winterMusicListRelay: BehaviorRelay<[MusicResultModel]>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        let top5MusicListRelay = BehaviorRelay<[MusicResultModel]>(value: [])
        let summerMusicListRelay = BehaviorRelay<[MusicResultModel]>(value: [])
        let fallMusicListRelay = BehaviorRelay<[MusicResultModel]>(value: [])
        let winterMusicListRelay = BehaviorRelay<[MusicResultModel]>(value: [])
        
        let top5Task = Task { [iTunesSearchAPIUseCase] in
            for await _ in input.viewDidLoad.values {
                let top5QueryDTO = iTunesQuery(term: MusicTerm.spring.rawValue, mediaType: .music, limit: 5)
                async let top5MusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: top5QueryDTO,
                                                                                       dtoType: MusicResultDTO.self,
                                                                                       transform: { $0.toModel() })
                do {
                    let result = try await top5MusicList
                    top5MusicListRelay.accept(result)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        let summerTask = Task { [iTunesSearchAPIUseCase] in
            for await _ in input.viewDidLoad.values {
                let summerQueryDTO = iTunesQuery(term: MusicTerm.summer.rawValue, mediaType: .music, limit: 15)
                async let summerMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: summerQueryDTO,
                                                                                         dtoType: MusicResultDTO.self,
                                                                                         transform: { $0.toModel() })
                do {
                    let results = try await summerMusicList
                    summerMusicListRelay.accept(results)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        let fallTask = Task { [iTunesSearchAPIUseCase] in
            for await _ in input.viewDidLoad.values {
                let fallQueryDTO = iTunesQuery(term: MusicTerm.fall.rawValue, mediaType: .music, limit: 15)
                async let fallMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: fallQueryDTO,
                                                                                       dtoType: MusicResultDTO.self,
                                                                                       transform: { $0.toModel() })
                do {
                    let results = try await fallMusicList
                    fallMusicListRelay.accept(results)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        let winterTask = Task { [iTunesSearchAPIUseCase] in
            for await _ in input.viewDidLoad.values {
                let winterQueryDTO = iTunesQuery(term: MusicTerm.winter.rawValue, mediaType: .music, limit: 15)
                async let winterMusicList = iTunesSearchAPIUseCase.fetchSearchResultList(with: winterQueryDTO,
                                                                                         dtoType: MusicResultDTO.self,
                                                                                         transform: { $0.toModel() })
                do {
                    let results = try await winterMusicList
                    winterMusicListRelay.accept(results)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        [top5Task, summerTask, fallTask, winterTask].forEach { fetchTask?.append($0) }
        
        return Output(top5MusicListRelay: top5MusicListRelay,
                      summerMusicListRelay: summerMusicListRelay,
                      fallMusicListRelay: fallMusicListRelay,
                      winterMusicListRelay: winterMusicListRelay)
    }
    
    // MARK: - Initializer
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
    
    deinit {
        fetchTask?.forEach { $0.cancel() }
        fetchTask = nil
    }
}
