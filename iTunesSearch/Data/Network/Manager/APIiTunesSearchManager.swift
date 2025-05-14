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
    
    /// iTunes Search API를 통해 music, movie, podcast 데이터를 비동기로 요청하고, 파싱된 모델 배열을 반환합니다.
    ///
    /// - Parameters:
    ///   - requestDTO: 검색어, 미디어 타입, 결과 수 제한 등을 포함한 요청 정보입니다.
    ///   - dtoType: 디코딩할 DTO 타입입니다.
    ///   - transform: DTO를 모델로 변환하는 클로저입니다.
    /// - Returns: 변환된 모델 배열.
    /// - Throws: URL 생성 실패, 네트워크 오류, 데이터 파싱 실패 시 에러를 던집니다.
    func fetchSearchResultList<DTO: Decodable, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) async throws -> [Model] {
        
        guard let urlRequest: URLRequest = NetworkEndpoints.urlRequest(.baseURL, term: requestDTO.term, mediaType: requestDTO.mediaType, limit: requestDTO.limit) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let successRange: Range = (200..<300)
        
        guard let httpResponse = response as? HTTPURLResponse,
              successRange.contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed
        }
        
        do {
            let responseDTO = try JSONDecoder().decode(ResponseDTO<DTO>.self, from: data)
            return responseDTO.results.map(transform)
        } catch {
            throw DataError.parsingFailed
        }
    }
    
    /// RxSwift Single을 사용해 iTunes Search API에서 music, movie, podcast 데이터를 요청하고 결과를 emit합니다.
    ///
    /// - Parameters:
    ///   - requestDTO: 검색어, 미디어 타입, 결과 수 제한 등을 포함한 요청 정보입니다.
    ///   - dtoType: 디코딩할 DTO 타입입니다.
    ///   - transform: DTO를 모델로 변환하는 클로저입니다.
    /// - Returns: 변환된 모델 배열을 emit하는 Single입니다.
    func rxFetchSearchResultList<DTO: Decodable, Model>(with requestDTO: RequestDTO, dtoType: DTO.Type, transform: @escaping (DTO) -> Model) -> Single<[Model]> {
        return Single.create { [weak self] single in
            Task {
                do {
                    if let models = try await self?.fetchSearchResultList(with: requestDTO,
                                                                          dtoType: dtoType,
                                                                          transform: transform) {
                        single(.success(models))
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
}
