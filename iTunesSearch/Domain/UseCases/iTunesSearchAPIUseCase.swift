//
//  iTunesSearchAPIUseCase.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

protocol iTunesSearchAPIUseCaseInterface {
    func fetchSearchResultList<DTO: Decodable, Model>(with iTunesQuery: iTunesQuery, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) async throws -> [Model]
}

final class iTunesSearchAPIUseCase: iTunesSearchAPIUseCaseInterface {
    
    private let repository: iTunesSearchAPIRepository
    
    init(repository: iTunesSearchAPIRepository) {
        self.repository = repository
    }
    
    func fetchSearchResultList<DTO: Decodable, Model>(with iTunesQuery: iTunesQuery, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) async throws -> [Model] {
        return try await repository.fetchSearchResultList(with: iTunesQuery, dtoType: dtoType, transform: transform)
    }
}
