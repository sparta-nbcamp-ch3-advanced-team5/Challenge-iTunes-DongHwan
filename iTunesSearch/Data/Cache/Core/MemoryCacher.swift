//
//  MemoryCacher.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

/// 메모리 캐싱 Actor
final actor MemoryCacher {
    
    // MARK: - Properties
    
    /// URL에 대한 이미지가 저장되는 캐시
    private let imageCache = NSCache<NSString, NSData>()
    
    /// 메모리 기반 이미지 캐싱을 관리하는 MemoryCacher를 초기화합니다.
    ///
    /// - Parameter maxCacheCount: 메모리에 보관할 수 있는 최대 캐시 개수입니다.
    init(maxCacheCount: Int) {
        imageCache.countLimit = maxCacheCount
    }
}

// MARK: - Caching Methods

extension MemoryCacher {
    /// 지정된 키에 해당하는 메모리 캐시에서 이미지 데이터를 가져옵니다.
    ///
    /// - Parameter key: 캐시된 이미지를 식별하는 고유 키입니다.
    /// - Returns: 이미지 데이터(존재하지 않으면 nil)를 반환합니다.
    func requestImage(key: String) async -> Data? {
        return imageCache.object(forKey: key as NSString) as? Data
    }
    
    /// 지정된 키로 이미지 데이터를 메모리에 저장합니다.
    ///
    /// - Parameters:
    ///   - key: 이미지를 저장할 고유 키입니다.
    ///   - imageData: 메모리에 저장할 이미지 데이터입니다.
    func cacheImage(key: String, imageData: Data) async {
        imageCache.setObject(imageData as NSData, forKey: key as NSString)
    }
}
