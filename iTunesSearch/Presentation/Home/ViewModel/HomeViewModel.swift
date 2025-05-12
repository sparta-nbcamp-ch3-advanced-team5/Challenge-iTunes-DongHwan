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

final class HomeViewModel {
    
    // MARK: - Properties
    
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: HomeViewModel.self))
    
//    private let apiiTunesSearchUseCase: APIiTunesSearchUseCase
    private let apiiTunesSearchUseCase = APIiTunesSearchManager()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        let top5MusicData: PublishRelay<MusicResultModel>
    }
    
    func transform(input: Input) -> Output {
        let top5MusicData = PublishRelay<MusicResultModel>()
        
        input.viewDidLoad
            .subscribe(with: self, onNext: { owner, _ in
                let musicRequestDTO = MusicRequestDTO(term: .spring, limit: 25)
                owner.apiiTunesSearchUseCase.getMusic(with: musicRequestDTO)
                    .subscribe { response in
                        os_log(.debug, log: owner.log, "%@", "\(response)")
                    } onFailure: { error in
                        os_log(.error, log: owner.log, "\(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
            }).disposed(by: disposeBag)
        
        return Output(top5MusicData: top5MusicData)
    }
    
    
    // MARK: - Initializer
    
//    init(apiiTunesSearchUseCase: APIiTunesSearchUseCase) {
//        self.apiiTunesSearchUseCase = apiiTunesSearchUseCase
//    }
}
