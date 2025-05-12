//
//  PodcastResultModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct PodcastResultModel: Hashable {
    /// 컨텐츠 종류
    let kind: String
    /// 진행자 이름
    let artistName: String
    /// 시리즈 이름
    let collectionName: String
    /// 팟캐스트 이름
    let trackName: String
    /// iTunes Store의 시리즈로 연결되는 URL
    let collectionViewURL: String
    let feedURL: String
    /// iTunes Store의 팟캐스트로 연결되는 URL
    let trackViewURL: String
    /// 30x30 픽셀의 썸네일
    let artworkUrl30: String?
    /// 60x60 픽셀의 썸네일
    let artworkUrl60: String?
    /// 100x100 픽셀의 썸네일
    let artworkUrl100: String?
    /// 시리즈 가격
    let collectionPrice: Double
    /// 팟캐스트 가격
    let trackPrice: Double
    /// 시리즈 HD 가격
    let collectionHDPrice: Double
    /// 출시일
    let releaseDate: String
    /// 팟캐스트 개수
    let trackCount: Int
    /// 팟캐스트 길이
    let trackTimeMillis: Int?
    /// 장르
    let primaryGenreName: String
    /// /// 600x600 픽셀의 썸네일
    let artworkUrl600: String
    /// iTunes Store에서 진행자로 연결되는 URL
    let artistViewURL: String?
}
