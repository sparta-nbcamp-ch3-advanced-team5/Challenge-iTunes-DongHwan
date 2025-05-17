//
//  SearchResultViewModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

/// 검색 결과 화면 ViewModel
final class SearchResultViewModel {
    
    // MARK: - Properties
    
    private let iTunesSearchAPIUseCase: iTunesSearchAPIUseCase
    
    /// 네트워크 통신 `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let searchText: Infallible<String>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    /// searchText, podcastList, movieList
    typealias SearchResultChunks = ([PodcastResultModel], [MovieResultModel])
    struct Output {
        let searchTextModelRelay: BehaviorRelay<[SearchTextModel]>
        let searchResultChunksRelay: BehaviorRelay<SearchResultChunks>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        let searchTextModelRelay = BehaviorRelay<[SearchTextModel]>(value: [])
        let searchResultChunksRelay = BehaviorRelay<SearchResultChunks>(value: ([], []))
        
        Task {
            for await text in input.searchText.values {
                let searchText = SearchTextModel(searchText: text)
                searchTextModelRelay.accept([searchText])
            }
        }
        
        fetchTask = Task { [iTunesSearchAPIUseCase] in
            for await text in input.searchText.debounce(.milliseconds(300), scheduler: MainScheduler.instance).values {
                let podcastQueryDTO = iTunesQuery(term: text, mediaType: .podcast, limit: 5)
                let movieQueryDTO = iTunesQuery(term: text, mediaType: .movie, limit: 10)

                async let podcastList = iTunesSearchAPIUseCase.fetchSearchResultList(with: podcastQueryDTO,
                                                                                     dtoType: PodcastResultDTO.self,
                                                                                     transform: { $0.toModel() })
                async let movieList = iTunesSearchAPIUseCase.fetchSearchResultList(with: movieQueryDTO,
                                                                                   dtoType: MovieResultDTO.self,
                                                                                   transform: { $0.toModel() })

                do {
                    let searchResultChunks = try await (podcastList, movieList)
                    searchResultChunksRelay.accept(searchResultChunks)
                } catch {
                    // TODO: - 에러 Alert 표시
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        return Output(searchTextModelRelay: searchTextModelRelay,
                      searchResultChunksRelay: searchResultChunksRelay)
    }
    
    // MARK: - Initializer
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
    
    deinit {
        // 네트워크 작업 취소
        fetchTask?.cancel()
        fetchTask = nil
    }
}
