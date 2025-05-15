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
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let iTunesSearchAPIUseCase: iTunesSearchAPIUseCase
    
    /// 네트워크 통신 Task 저장(deinit 될 때 실행 중단용)
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Infallible<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    // top5, summer, fall, winter
    typealias SearchResultChunks = ([SearchTextModel], [PodcastResultModel], [MovieResultModel])
    struct Output {
        let searchResultChunksRelay: BehaviorRelay<SearchResultChunks>
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func transform(input: Input) -> Output {
        let searchResultChunksRelay = BehaviorRelay<SearchResultChunks>(value: ([], [], []))
        
//        fetchTask = Task { [weak self] in
//            for await _ in input.viewDidLoad.values {
//                let podcastQueryDTO = iTunesQuery(term: <#T##String#>, mediaType: <#T##MediaType#>, limit: <#T##Int#>)
//            }
//        }
        
        return Output(searchResultChunksRelay: searchResultChunksRelay)
    }
    
    // MARK: - Initializer
    
    init(iTunesSearchAPIUseCase: iTunesSearchAPIUseCase) {
        self.iTunesSearchAPIUseCase = iTunesSearchAPIUseCase
    }
    
    deinit {
        fetchTask?.cancel()
        fetchTask = nil
    }
}
