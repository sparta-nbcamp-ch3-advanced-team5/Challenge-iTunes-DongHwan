//
//  iTunesSearchAPIUseCase.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

import RxSwift

protocol iTunesSearchAPIUseCaseInterface {
    func rxFetchSearchResultList<DTO: Decodable, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) -> Single<[Model]>
}

final class iTunesSearchAPIUseCase: iTunesSearchAPIUseCaseInterface {
    
    private let repository: iTunesSearchAPIRepository
    
    init(repository: iTunesSearchAPIRepository) {
        self.repository = repository
    }
    
    func rxFetchSearchResultList<DTO, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) -> Single<[Model]> where DTO : Decodable {
        repository.rxFetchSearchResultList(with: requestDTO, dtoType: dtoType, transform: transform)
    }
}
