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
    /// iTunes Search API에 음악 데이터 요청
    func fetchMusicList(with musicRequstDTO: MusicRequestDTO) -> Single<[MusicResultModel]> {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        return Single<[MusicResultModel]>.create { single in
            guard let urlRequest: URLRequest = NetworkEndpoints.urlRequest(.baseURL, term: musicRequstDTO.term.rawValue, mediaType: .music, limit: musicRequstDTO.limit) else {
                single(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            os_log(.debug, log: log, "\(urlRequest)")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                let successRange: Range = (200..<300)
                
                guard let data, error == nil else {
                    single(.failure(NetworkError.noData))
                    return
                }
                
                if let response: HTTPURLResponse = response as? HTTPURLResponse {
                    os_log(.debug, log: log, "statusCode: \(response.statusCode)")
                    
                    if successRange.contains(response.statusCode) {
                        os_log(.debug, log: log, "data: \(data)")
                        do {
                            let responseDTO = try JSONDecoder().decode(ResponseDTO<MusicResultDTO>.self, from: data)
//                            os_log(.debug, log: log, "responseDTO: \(responseDTO)")
                            let musicModelList = responseDTO.results.map { $0.toMusicModel() }
                            single(.success(musicModelList))
                        } catch {
                            os_log(.error, log: log, "\(error)")
                            single(.failure(DataError.parsingFailed))
                        }
                    } else {
                        single(.failure(NetworkError.requestFailed))
                    }
                }
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
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
