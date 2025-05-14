//
//  ImageCacheManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation
import OSLog

import RxSwift

/// 이미지 캐시 매니저
final class ImageCacheManager {
    
    // MARK: - Properties
    
    private let memoryCacher = MemoryCacher(maxCacheCount: 50)
    private let diskCacher = DiskCacher(diskCacheTracker: DiskCacheTracker(maxCount: 100),
                                        maxFileCount: 100,
                                        fileCountForDeleteWhenOverflow: 20)
    
    // MARK: - Initializer
    
    /// ImageCacheManager 싱글톤 인스턴스
    static let shared = ImageCacheManager()
    private init() {}
    
    // MARK: - Image Methods
    
    /// 주어진 URL에서 이미지 데이터를 비동기로 다운로드합니다.
    ///
    /// - Parameter urlString: 이미지 리소스의 URL 문자열입니다.
    /// - Returns: 다운로드된 이미지 데이터.
    /// - Throws: URL 생성 실패 또는 네트워크 오류 발생 시 에러를 던집니다.
    func fetchImage(from urlString: String) async throws -> Data {
        // URL 생성
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // URLSessionConfiguration.ephemeral: NSCache를 따로 사용하므로 URLSession의 캐시를 사용하지 않음
        let (imageData, _) = try await URLSession(configuration: URLSessionConfiguration.ephemeral).data(from: url)
        
        return imageData
    }
    
    /// RxSwift Single을 사용해 이미지 로드를 제공합니다. 메모리/디스크 캐시를 우선 확인하고, 없으면 네트워크에서 가져옵니다.
    ///
    /// - Parameter urlString: 이미지 리소스의 URL 문자열입니다.
    /// - Returns: 캐시 또는 네트워크로부터 가져온 이미지 데이터를 emit하는 Single<Data>입니다.
    func rxFetchImage(from urlString: String) -> Single<Data> {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
        
        return Single<Data>.create { [weak self] single in
            Task {
                // 메모리에 캐시된 이미지 확인
                if let memoryCachedImageData = await self?.memoryCacher.requestImage(key: urlString) {
                    os_log(.debug, log: log, "메모리에 캐시된 이미지 반환")
                    single(.success(memoryCachedImageData))
                }
                
                // 디스크에 캐시된 이미지 확인
                if let diskCachedImage = await self?.diskCacher.requestImage(key: urlString) {
                    await self?.memoryCacher.cacheImage(key: urlString, imageData: diskCachedImage)
                    os_log(.debug, log: log, "디스크에 캐시된 이미지 반환")
                    single(.success(diskCachedImage))
                }
                
                do {
                    // 네트워크 통신 및 이미지 fetch
                    let imageData = try await self?.fetchImage(from: urlString)
                    if let imageData {
                        // fetch된 이미지를 캐시에 저장
                        await self?.memoryCacher.cacheImage(key: urlString, imageData: imageData)
                        await self?.diskCacher.cacheImage(key: urlString, imageData: imageData)
                        os_log(.debug, log: log, "이미지 캐싱 성공")
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
    }
}
