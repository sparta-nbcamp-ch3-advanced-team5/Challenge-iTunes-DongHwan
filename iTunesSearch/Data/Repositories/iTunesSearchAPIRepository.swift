//
//  iTunesSearchAPIRepository.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

import RxSwift

final class iTunesSearchAPIRepository: iTunesSearchAPIRepositoryInterface {
    
    private let manager = iTunesSearchAPIManager()
    
    func rxFetchSearchResultList<DTO, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) -> Single<[Model]> where DTO : Decodable {
        manager.rxFetchSearchResultList(with: requestDTO, dtoType: dtoType, transform: transform)
    }
}
