//
//  DiskCacheTracker.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

/// 디스크 캐싱 트래커 Actor
final actor DiskCacheTracker {
    
    // MARK: - Properties
    
    private let maxCount: Int
    
    private let store = UserDefaults()
    private let dictKey = "DiskCacheTracker"
    private var diskCacheInfo = [String: Date]()
    
    /// 캐시된 파일 개수가 최대 개수(maxCount)에 도달했는지 여부를 반환합니다.
    var isDiskFull: Bool {
        return diskCacheInfo.keys.count >= maxCount
    }
    
    // MARK: - Initializer
    
    /// DiskCacheTracker를 초기화합니다.
    ///
    /// - Parameter maxCount: 캐시에 저장할 수 있는 최대 항목 수입니다.
    init(maxCount: Int) {
        self.maxCount = maxCount
    }
}

// MARK: - Disk Info Caching Methods

extension DiskCacheTracker {
    /// 현재 디스크 캐시 정보를 UserDefaults에 저장합니다.
    private func saveCurrentDict() {
        store.set(diskCacheInfo, forKey: dictKey)
    }
    
    /// UserDefaults에 저장된 모든 캐시 정보를 삭제합니다.
    func clearStore() {
        store.removeObject(forKey: dictKey)
    }

    /// 캐시된 항목 중 가장 오래된 키를 지정된 개수만큼 반환합니다.
    ///
    /// - Parameter count: 반환할 오래된 항목의 개수입니다.
    /// - Returns: 오래된 순서대로 정렬된 키 배열입니다.
    func loadOldestCacheInfo(count: Int) -> [String] {
        let sortedInfo = diskCacheInfo.sorted { $0.value < $1.value }
        if sortedInfo.count <= count {
            return sortedInfo.map { $0.key }
        }
        return sortedInfo[0..<count].map { $0.key }
    }
    
    /// 새로운 캐시 항목 정보를 생성하고 저장합니다.
    ///
    /// - Parameters:
    ///   - key: 캐시 항목의 고유 키입니다.
    ///   - value: 캐시 생성 또는 마지막 업데이트 시각입니다.
    func createCacheInfo(key: String, value: Date) {
        diskCacheInfo[key] = value
        saveCurrentDict()
    }
    
    /// 지정된 키에 대한 캐시 정보를 조회합니다.
    ///
    /// - Parameter key: 조회할 캐시 항목의 키입니다.
    /// - Returns: 해당 키의 마지막 접근 시각 또는 nil입니다.
    func loadCacheInfo(key: String) -> Date? {
        return diskCacheInfo[key]
    }
    
    /// 기존 캐시 항목의 접근 시각을 업데이트하고 저장합니다.
    ///
    /// - Parameters:
    ///   - key: 업데이트할 캐시 항목의 키입니다.
    ///   - value: 새로운 마지막 접근 시각입니다.
    func updateCacheInfo(key: String, value: Date) {
        diskCacheInfo[key] = value
        saveCurrentDict()
    }
    
    /// 지정된 키의 캐시 정보를 삭제하고 저장합니다.
    ///
    /// - Parameter key: 삭제할 캐시 항목의 키입니다.
    func deleteCacheInfo(key: String) {
        diskCacheInfo.removeValue(forKey: key)
        saveCurrentDict()
    }
}
