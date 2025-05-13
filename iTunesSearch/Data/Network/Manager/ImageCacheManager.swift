//
//  ImageCacheManager.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

import RxSwift

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
    
    /// 이미지 로드
    func loadImage(from urlString: String) -> Single<Data> {
        let key = urlString as NSString
        
        return Single<Data>.create { [weak self] single in
            
            // 캐시된 이미지 확인
            if let cachedImageData = self?.cachedImages.object(forKey: key) {
                single(.success(cachedImageData as Data))
                return Disposables.create()
            }
            
            // URL 생성
            guard let url = URL(string: urlString) else {
                single(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            // 네트워크 통신 및 이미지 fetch
            // URLSessionConfiguration.ephemeral: NSCache를 따로 사용하므로 URLSession의 캐시를 사용하지 않음
            let task = URLSession(configuration: URLSessionConfiguration.ephemeral).dataTask(with: url) { imageData, _, error in
                // error와 data를 확인하고 이미지 생성 시도
                guard let imageData, error == nil else {
                    DispatchQueue.main.async {
                        single(.failure(NetworkError.noData))
                    }
                    return
                }
                // fetch된 이미지를 캐시에 저장
                self?.cachedImages.setObject(imageData as NSData, forKey: key)
                single(.success(imageData))
            }
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
        .asObservable()
        .share(replay: 1, scope: .whileConnected)
        .asSingle()
    }
}
