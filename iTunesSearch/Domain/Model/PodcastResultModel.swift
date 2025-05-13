//
//  PodcastResultModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct PodcastResultModel: Hashable {
    /// 진행자 이름
    let artistName: String
    /// 시리즈 이름
    let collectionName: String
    /// 팟캐스트 이름
    let trackName: String
    /// iTunes Store에서 진행자로 연결되는 URL
    let artistViewURL: String?
    /// iTunes Store의 시리즈로 연결되는 URL
    let collectionViewURL: String
    /// ?
    let feedURL: String?
    /// iTunes Store의 팟캐스트로 연결되는 URL
    let trackViewURL: String
    /// 100x100 픽셀의 썸네일 URL
    let artworkUrl100: String
    /// 출시일
    let releaseDate: String
    /// 팟캐스트 개수
    let trackCount: Int
    /// 팟캐스트 길이
    let trackTimeMillis: Int?
    /// 장르
    let primaryGenreName: String
    /// 600x600 픽셀의 썸네일 URL
    let artworkUrl600: String
}
