//
//  MovieResultModel.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct MovieResultModel {
    /// 컨텐츠 종류
    let kind: String
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
    /// 30초 프리뷰를 재생할 수 있는 URL
    let previewURL: String?
    /// 30x30 픽셀의 썸네일
    let artworkUrl30: String?
    /// 60x60 픽셀의 썸네일
    let artworkUrl60: String?
    /// 100x100 픽셀의 썸네일
    let artworkUrl100: String?
    /// 시리즈 가격
    let collectionPrice: Double?
    /// 영화 가격
    let trackPrice: Double?
    /// 시리즈 HD 가격
    let collectionHDPrice: Double?
    /// 영화 HD 가격
    let trackHDPrice: Double?
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
    /// 긴 설명
    let longDescription: String
    let hasITunesExtras: Bool?
    /// 영화 대여 가격
    let trackRentalPrice: Double?
    /// 영화 HD 대여 가격
    let trackHDRentalPrice: Double?
    /// 짧은 설명
    let shortDescription: String?
    /// iTunes Store에서 감독으로 연결되는 URL
    let artistViewURL: String?
}
