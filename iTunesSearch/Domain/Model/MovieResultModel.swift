//
//  MovieResultModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct MovieResultModel: Hashable {
    let id = UUID()
    /// 감독 이름
    let artistName: String
    /// 시리즈 이름
    let collectionName: String?
    /// 영화 이름
    let trackName: String
    /// iTunes Store의 시리즈 감독으로 연결되는 URL
    let collectionArtistViewURL: String?
    /// iTunes Store의 시리즈로 연결되는 URL
    let collectionViewURL: String?
    /// iTunes Store의 영화로 연결되는 URL
    let trackViewURL: String
    /// 100x100 픽셀의 썸네일 URL
    let artworkUrl100: String
    /// 출시일
    let releaseDate: String
    /// 디스크 개수
    let discCount: Int?
    /// 디스크 번호
    let discNumber: Int?
    /// 시리즈 개수
    let trackCount: Int?
    /// 시리즈 번호
    let trackNumber: Int?
    /// 러닝타임
    let trackTimeMillis: Int?
    /// 장르
    let primaryGenreName: String
    /// 짧은 설명
    let shortDescription: String?
    /// 긴 설명
    let longDescription: String
    /// ?
    let hasITunesExtras: Bool?
    /// 배경 사진 UIImageView 배경색 Hex
    let backgroundArtistImageColorHex: String
}
