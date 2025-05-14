//
//  APIiTunesSearchManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation
import OSLog

import RxSwift

/// iTunes Search API 호출 매니저
final class APIiTunesSearchManager {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    // MARK: - Network Methods
    
    /// iTunes Search API로 음악 데이터 Fetch 및 파싱하여 반환
    func fetchMusicList(with musicRequestDTO: MusicRequestDTO) async throws -> [MusicResultModel] {
        
        guard let urlRequest: URLRequest = NetworkEndpoints.urlRequest(.baseURL, term: musicRequestDTO.term.rawValue, mediaType: .music, limit: musicRequestDTO.limit) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let successRange: Range = (200..<300)
        
        guard let httpResponse = response as? HTTPURLResponse,
              successRange.contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed
        }
        
        do {
            let responseDTO = try JSONDecoder().decode(ResponseDTO<MusicResultDTO>.self, from: data)
            let musicModelList = responseDTO.results.map { $0.toMusicModel() }
            return musicModelList
        } catch {
            throw DataError.parsingFailed
        }
    }
    
    /// iTunes Search API에 음악 데이터 요청을 보내고, 파싱된 데이터를 받아 RxSwift Single로 방출
    func rxFetchMusicList(with musicRequestDTO: MusicRequestDTO) -> Single<[MusicResultModel]> {
        return Single.create { [weak self] single in
            Task {
                do {
                    let dto = try await self?.fetchMusicList(with: musicRequestDTO)
                    if let dto {
                        single(.success(dto))
                    } else {
                        single(.failure(DataError.fileNotFound))
                    }
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    // TODO: Movies API 호출 코드 만들기
    /// iTunes Search API에 영화 데이터 요청
//    func fetchMovieList(with movieRequestDTO: MovieRequestDTO) -> Single<ResponseDTO> {
//    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
//
//    }
    
    // TODO: Podcast API 호출 코드 만들기
}
