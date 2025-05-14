//
//  iTunesSearchAPIRepositoryInterface.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

import RxSwift

protocol iTunesSearchAPIRepositoryInterface {
    func rxFetchSearchResultList<DTO: Decodable, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) -> Single<[Model]>
}
