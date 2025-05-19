//
//  ImageCacheManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation
import OSLog

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
    
    /// 주어진 URL을 키값으로 메모리/디스크 캐시에서 이미지를 우선 확인하고, 없으면 URL에서 이미지 데이터를 비동기로 다운로드합니다.
    ///
    /// - Parameter urlString: 이미지 리소스의 URL 문자열입니다.
    /// - Returns: 캐시 또는 네트워크로부터 가져온 이미지 데이터.
    /// - Throws: URL 생성 실패 또는 네트워크 오류 발생 시 에러를 던집니다.
    func fetchImage(from urlString: String) async throws -> Data {
        // 1. 메모리에 캐시된 이미지 확인
        if let memoryCachedImageData = await memoryCacher.requestImage(key: urlString) {
            return memoryCachedImageData
        }
        
        // 2. 디스크에 캐시된 이미지 확인
        if let diskCachedImage = await diskCacher.requestImage(key: urlString) {
            await memoryCacher.cacheImage(key: urlString, imageData: diskCachedImage)
            return diskCachedImage
        }
        
        // 3. 네트워크에서 이미지 fetch
        // URLSessionConfiguration.ephemeral: NSCache를 따로 사용하므로 URLSession의 캐시를 사용하지 않음
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (imageData, _) = try await URLSession(configuration: URLSessionConfiguration.ephemeral).data(from: url)
        await memoryCacher.cacheImage(key: urlString, imageData: imageData)
        await diskCacher.cacheImage(key: urlString, imageData: imageData)
        
        return imageData
    }
}
