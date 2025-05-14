//
//  DiskCacher.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/14/25.
//

import Foundation

/// 디스크 캐싱 Actor
final actor DiskCacher {
    
    // MARK: - Properties
    
    private let fileManager = FileManager()
    
    private let diskCacheTracker: DiskCacheTracker
    
    private let maxFileCount: Int
    private let fileCountForDeleteWhenOverflow: Int
    
    /// 디스크 기반 이미지 캐싱을 관리하는 DiskCacher를 초기화합니다.
    ///
    /// - Parameters:
    ///   - diskCacheTracker: 캐시된 파일의 메타데이터를 관리하는 트래커입니다.
    ///   - maxFileCount: 캐시에 보관할 수 있는 최대 파일 개수입니다.
    ///   - fileCountForDeleteWhenOverflow: 캐시 용량 초과 시 삭제할 오래된 파일 개수입니다.
    init(
        diskCacheTracker: DiskCacheTracker,
        maxFileCount: Int,
        fileCountForDeleteWhenOverflow: Int
    ) {
        self.diskCacheTracker = diskCacheTracker
        self.maxFileCount = maxFileCount
        self.fileCountForDeleteWhenOverflow = fileCountForDeleteWhenOverflow
        
        Task {
            await createCacheDirectory()
        }
    }
}

// MARK: - Caching Methods

extension DiskCacher {
    /// 지정된 키에 해당하는 디스크 캐시에서 이미지 데이터를 가져옵니다.
    ///
    /// - Parameter key: 캐시된 이미지를 식별하는 고유 키입니다.
    /// - Returns: 이미지 데이터(존재하지 않으면 nil). 호출 시 캐시 접근 시간이 업데이트됩니다.
    func requestImage(key: String) async -> Data? {
        guard let imageFilePath = createImagePath(key: key) else {
            return nil
        }
        let imageData = loadImageData(path: imageFilePath.path)
        await diskCacheTracker.updateCacheInfo(key: key, value: .now)
        return imageData
    }
    
    /// 지정된 키로 이미지 데이터를 디스크에 저장합니다.
    ///
    /// - Parameters:
    ///   - key: 이미지를 저장할 고유 키입니다.
    ///   - imageData: 디스크에 기록할 이미지 데이터입니다.
    func cacheImage(key: String, imageData: Data) async {
        await cacheImageFileToDisk(key: key, imageData: imageData)
    }
}

// MARK: - File Management

private extension DiskCacher {
    /// 앱의 Caches 폴더 아래에 캐시 디렉터리를 생성합니다. 이미 존재하면 아무 작업도 하지 않습니다.
    func createCacheDirectory() {
        guard var cacheDictionaryPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        cacheDictionaryPath = cacheDictionaryPath.appending(path: "CachedDiskImage")
        if !fileManager.fileExists(atPath: cacheDictionaryPath.path()) {
            try? fileManager.createDirectory(at: cacheDictionaryPath, withIntermediateDirectories: true)
        }
    }
    
    /// 지정된 경로에서 이미지 데이터를 읽어옵니다.
    ///
    /// - Parameter path: 이미지 파일의 전체 파일 시스템 경로입니다.
    /// - Returns: 파일이 존재하면 데이터, 그렇지 않으면 nil을 반환합니다.
    func loadImageData(path: String) -> Data? {
        guard let imageData = fileManager.contents(atPath: path) else {
            return nil
        }
        
        return imageData
    }
    
    /// 키를 기반으로 캐시된 이미지의 파일 URL을 생성합니다.
    ///
    /// - Parameter key: 이미지를 식별하는 고유 키입니다.
    /// - Returns: 이미지가 저장될 URL, 생성 실패 시 nil을 반환합니다.
    func createImagePath(key: String) -> URL? {
        guard let cacheDictionaryPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let imageDirectoryPath = cacheDictionaryPath.appending(path: "CachedDiskImage")
        let imageFileName = createSafeFileName(draft: key as String)
        let imageFileURL = imageDirectoryPath.appending(path: imageFileName)
        return imageFileURL
    }
    
    /// 원본 문자열의 특수 문자를 대체하여 파일 시스템에 안전한 파일 이름을 생성합니다.
    ///
    /// - Parameter draft: 변환할 원본 문자열입니다.
    /// - Returns: 안전하게 변환된 파일 이름을 반환합니다.
    func createSafeFileName(draft: String) -> String {
        let unsafeCharacters: [String] = [
            "/",":","?","=","&","%","#"," ","\"","'","<",">","\\","|","*",";"
        ]
        var safeFileName = draft
        
        // 특수 문자를 "-"로 변환
        for unsafe in unsafeCharacters {
            safeFileName = safeFileName.replacingOccurrences(of: unsafe, with: "-")
        }
        return safeFileName
    }
    
    /// 이미지 데이터를 디스크에 기록합니다. 캐시가 용량을 초과하면 오래된 파일을 삭제합니다.
    ///
    /// - Parameters:
    ///   - key: 이미지를 저장할 고유 키입니다.
    ///   - imageData: 디스크에 기록할 이미지 데이터입니다.
    func cacheImageFileToDisk(key: String, imageData: Data) async {
        guard let imageFilePath = createImagePath(key: key) else {
            return
        }
        
        if await diskCacheTracker.isDiskFull {
            let removableList = await diskCacheTracker.loadOldestCacheInfo(count: fileCountForDeleteWhenOverflow)
            for removeKey in removableList {
                guard let stringPath = createImagePath(key: removeKey)?.path() else {
                    continue
                }
                if fileManager.fileExists(atPath: stringPath) {
                    try? fileManager.removeItem(atPath: stringPath)
                    await diskCacheTracker.deleteCacheInfo(key: removeKey)
                }
            }
        }
        
        let imageFileCreationResult = fileManager.createFile(atPath: imageFilePath.path(), contents: imageData)
        if imageFileCreationResult {
            await diskCacheTracker.createCacheInfo(key: key, value: .now)
        }
    }
}
