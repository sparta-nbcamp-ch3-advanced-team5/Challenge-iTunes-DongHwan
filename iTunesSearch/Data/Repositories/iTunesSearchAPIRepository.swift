//
//  iTunesSearchAPIRepository.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

final class iTunesSearchAPIRepository: iTunesSearchAPIRepositoryInterface {
    
    private let manager = iTunesSearchAPIManager()
    
    func fetchSearchResultList<DTO: Decodable, Model>(with iTunesQuery: iTunesQuery, dtoType: DTO.Type, transform: (DTO) -> Model) async throws -> [Model] {
        return try await manager.fetchSearchResultList(with: iTunesQuery, dtoType: dtoType, transform: transform)
    }
}
