//
//  MusicResultModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct MusicResultModel: Hashable {
    /// 아티스트 이름
    let artistName: String
    /// 앨범 이름
    let collectionName: String?
    /// 노래 이름
    let trackName: String
    /// iTunes Store의 아티스트로 연결되는 URL
    let artistViewURL: String
    /// iTunes Store의 앨범으로 연결되는 URL
    let collectionViewURL: String?
    /// iTunes Store의 노래로 연결되는 URL
    let trackViewURL: String
    /// 100x100 픽셀의 썸네일 URL
    let artworkUrl100: String
    /// 출시일
    let releaseDate: String
    /// 디스크 개수
    let discCount: Int?
    /// 디스크 번호
    let discNumber: Int?
    /// 노래 트랙 개수
    let trackCount: Int?
    /// 노래 트랙 번호
    let trackNumber: Int?
    /// 노래 길이
    let trackTimeMillis: Int?
    /// 장르
    let primaryGenreName: String
    /// 앨범 아티스트 이름
    let collectionArtistName: String?
    /// iTunes Store의 앨범 아티스트로 연결되는 URL
    let collectionArtistViewURL: String?
    /// 가수 사진 UIImageView 배경색 Hex
    let backgroundArtistImageColorHex: String
}
