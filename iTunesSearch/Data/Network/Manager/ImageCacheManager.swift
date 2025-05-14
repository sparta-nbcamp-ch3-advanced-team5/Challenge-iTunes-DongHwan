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
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let memoryCacher: MemoryCacher
    private let diskCacher: DiskCacher
    
    // MARK: - Initializer
    
    static let shared: ImageCacheManager = .init(memoryCacher: MemoryCacher(maxCacheCount: 50),
                                                 diskCacher: DiskCacher(diskCacheTracker: DiskCacheTracker(maxCount: 100),
                                                                        maxFileCount: 100,
                                                                        fileCountForDeleteWhenOverflow: 20))
    
    /// ImageCacheManager 싱글톤 인스턴스를 초기화합니다.
    ///
    /// - Parameters:
    ///   - memoryCacher: 메모리 캐시 관리를 담당하는 인스턴스입니다.
    ///   - diskCacher: 디스크 캐시 관리를 담당하는 인스턴스입니다.
    private init(
        memoryCacher: MemoryCacher,
        diskCacher: DiskCacher
    ) {
        self.memoryCacher = memoryCacher
        self.diskCacher = diskCacher
    }
    
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
    func rxFetchImage(from urlString: String) async -> Single<Data> {
        // 메모리에 캐시된 이미지 확인
        if let memoryCachedImageData = await memoryCacher.requestImage(key: urlString) {
            os_log(.debug, log: log, "메모리에 캐시된 이미지 반환")
            return .just(memoryCachedImageData)
        }
        
        // 디스크에 캐시된 이미지 확인
        if let diskCachedImage = await diskCacher.requestImage(key: urlString) {
            await memoryCacher.cacheImage(key: urlString, imageData: diskCachedImage)
            os_log(.debug, log: log, "디스크에 캐시된 이미지 반환")
            return .just(diskCachedImage)
        }
        
        return Single<Data>.create { [weak self] single in
            Task {
                do {
                    // 네트워크 통신 및 이미지 fetch
                    let imageData = try await self?.fetchImage(from: urlString)
                    if let imageData {
                        // fetch된 이미지를 캐시에 저장
                        await self?.memoryCacher.cacheImage(key: urlString, imageData: imageData)
                        await self?.diskCacher.cacheImage(key: urlString, imageData: imageData)
                        guard let self else { return }
                        os_log(.debug, log: self.log, "이미지 캐싱 성공")
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
