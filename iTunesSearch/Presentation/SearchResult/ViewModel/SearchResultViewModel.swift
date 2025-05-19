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
    
    private let podcastQueryLimit = 5
    private var movieQueryLimit = 10
    
    private var podcastList = [PodcastResultModel]()
    private var movieList = [MovieResultModel]()
    
    /// 네트워크 작업(검색) `Task` 저장(`deinit` 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    /// 네트워크 작업(추가 로딩) `Task` 저장(`deinit` 될 때, 검색어 변경됐을 때 실행 중단용)
    private var loadingMoreTask: Task<Void, Never>?
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let searchText: Infallible<String>
        let didScrolledBottom: Infallible<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    /// searchText, podcastList, movieList
    typealias SearchResultChunks = ([SearchTextModel], [PodcastResultModel], [MovieResultModel])
    struct Output {
        let searchResultChunksRelay: BehaviorRelay<SearchResultChunks>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        let searchResultChunksRelay = BehaviorRelay<SearchResultChunks>(value: ([], [], []))
    
        fetchTask = Task { [iTunesSearchAPIUseCase] in
            for await searchText in input.searchText.debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance).distinctUntilChanged().values {
                loadingMoreTask?.cancel()
                
                movieQueryLimit = 10
                
                let podcastQueryDTO = iTunesQuery(term: searchText, mediaType: MediaType.podcast.rawValue, limit: podcastQueryLimit)
                let movieQueryDTO = iTunesQuery(term: searchText, mediaType: MediaType.movie.rawValue, limit: movieQueryLimit)
                os_log(.debug, log: log, "fetchTask: \(self.podcastQueryLimit), \(self.movieQueryLimit)")
                
                let searchText = SearchTextModel(searchText: searchText)
                async let podcastList = iTunesSearchAPIUseCase.fetchSearchResultList(with: podcastQueryDTO,
                                                                                     dtoType: PodcastResultDTO.self,
                                                                                     transform: { $0.toModel() })
                async let movieList = iTunesSearchAPIUseCase.fetchSearchResultList(with: movieQueryDTO,
                                                                                   dtoType: MovieResultDTO.self,
                                                                                   transform: { $0.toModel() })

                do {
                    let searchResultChunks = try await ([searchText], podcastList, movieList)
                    self.podcastList = searchResultChunks.1
                    self.movieList = searchResultChunks.2
                    searchResultChunksRelay.accept(searchResultChunks)
                } catch {
                    // TODO: - 에러 Alert 표시
                    searchResultChunksRelay.accept(([searchText], self.podcastList, self.movieList))
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        loadingMoreTask = Task { [iTunesSearchAPIUseCase] in
            let infallible = input.didScrolledBottom.debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
                .withLatestFrom(input.searchText.debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance).distinctUntilChanged())
            for await searchText in infallible.values {
                movieQueryLimit += 10
                os_log(.debug, log: log, "loadingMoreTask: \(self.podcastQueryLimit), \(self.movieQueryLimit)")
                let podcastQueryDTO = iTunesQuery(term: searchText, mediaType: MediaType.podcast.rawValue, limit: podcastQueryLimit)
                let movieQueryDTO = iTunesQuery(term: searchText, mediaType: MediaType.movie.rawValue, limit: movieQueryLimit)
                
                let searchText = SearchTextModel(searchText: searchText)
                async let podcastList = iTunesSearchAPIUseCase.fetchSearchResultList(with: podcastQueryDTO,
                                                                                     dtoType: PodcastResultDTO.self,
                                                                                     transform: { $0.toModel() })
                async let movieList = iTunesSearchAPIUseCase.fetchSearchResultList(with: movieQueryDTO,
                                                                                   dtoType: MovieResultDTO.self,
                                                                                   transform: { $0.toModel() })
                
                do {
                    let searchResultChunks = try await ([searchText], podcastList, movieList)
                    if self.movieList.count == searchResultChunks.1.count {
                        movieQueryLimit -= 10
                    }
                    self.podcastList = searchResultChunks.1
                    self.movieList = searchResultChunks.2
                    searchResultChunksRelay.accept(searchResultChunks)
                } catch {
                    // TODO: - 에러 Alert 표시
                    movieQueryLimit -= 10
                    searchResultChunksRelay.accept(([searchText], self.podcastList, self.movieList))
                    os_log(.error, log: log, "\(error.localizedDescription)")
                }
            }
        }
        
        return Output(searchResultChunksRelay: searchResultChunksRelay)
    }
    
    // MARK: - Initializer
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
    
    deinit {
        // 네트워크 작업 취소
        fetchTask?.cancel()
        loadingMoreTask?.cancel()
    }
}
