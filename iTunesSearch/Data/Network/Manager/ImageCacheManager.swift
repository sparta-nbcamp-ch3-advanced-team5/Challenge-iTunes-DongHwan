//
//  ImageCacheManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

import RxSwift

/// 이미지 캐시 매니저
final class ImageCacheManager {
    
    // MARK: - Properties
    
    /// ImageCacheManager 싱글톤
    static let shared = ImageCacheManager()
    private init() {}
    
    /// URL에 대한 이미지가 저장되는 캐시
    private let cachedImages = NSCache<NSString, NSData>()
    /// 디스크 저장용 딕셔너리
//    private var cacheInfoDict: [NSString: ImageCacheInfoDTO] {
//        if let dict = UserDefaults.standard.dictionary(forKey: Key.)
//    }
    
    // MARK: - Image Methods
    
    /// 네트워크에서 이미지 Fetch하여 반환
    func fetchImage(from urlString: String) async throws -> Data {
        // URL 생성
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // URLSessionConfiguration.ephemeral: NSCache를 따로 사용하므로 URLSession의 캐시를 사용하지 않음
        let (imageData, _) = try await URLSession(configuration: URLSessionConfiguration.ephemeral).data(from: url)
        
        return imageData
    }
    
    /// 네트워크에 이미지 요청을 보내고, Fetch된 데이터를 받아 RxSwift Single로 방출
    func rxGetImage(from urlString: String) -> Single<Data> {
        let key = urlString as NSString
        
        return Single<Data>.create { [weak self] single in
            // TODO: 디스크 캐싱
            
            // 캐시된 이미지 확인
            if let cachedImageData = self?.cachedImages.object(forKey: key) {
                single(.success(cachedImageData as Data))
                return Disposables.create()
            }
            
            Task {
                do {
                    // 네트워크 통신 및 이미지 fetch
                    let imageData = try await self?.fetchImage(from: urlString)
                    if let imageData {
                        // fetch된 이미지를 캐시에 저장
                        self?.cachedImages.setObject(imageData as NSData, forKey: urlString as NSString)
                        single(.success(imageData))
                    } else {
                        single(.failure(DataError.fileNotFound))
                    }
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
        .asObservable()
        .share(replay: 1, scope: .whileConnected)
        .asSingle()
    }
}
