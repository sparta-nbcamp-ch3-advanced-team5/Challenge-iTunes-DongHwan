//
//  APIiTunesSearchManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation
import OSLog

import RxSwift

/// iTunes Search API 호출을 관리하는 매니저입니다.
/// 
/// 음악, 영화, 팟캐스트 등 다양한 미디어 검색 요청을 처리합니다.
final class APIiTunesSearchManager {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    // MARK: - Network Methods
    
    /// iTunes Search API를 통해 음악 데이터를 비동기로 요청하고, 파싱된 결과를 반환합니다.
    ///
    /// - Parameter musicRequestDTO: 검색어, 미디어 타입, 결과 수 제한 등을 포함한 요청 정보입니다.
    /// - Returns: 파싱된 MusicResultModel 배열.
    /// - Throws: URL 생성 실패, 네트워크 오류, 데이터 파싱 실패 시 에러를 던집니다.
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
    
    /// RxSwift Single을 사용해 iTunes Search API에서 음악 데이터를 요청하고 결과를 emit합니다.
    ///
    /// - Parameter musicRequestDTO: 검색어, 미디어 타입, 결과 수 제한 등을 포함한 요청 정보입니다.
    /// - Returns: 파싱된 MusicResultModel 배열을 emit하는 Single.
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
