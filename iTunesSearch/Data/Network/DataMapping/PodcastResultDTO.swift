//
//  PodcastResultDTO.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

// MARK: - Result
struct PodcastResultDTO: Decodable {
    let wrapperType: String
    let kind: String
    let collectionID, trackID: Int
    let artistName, collectionName, trackName, collectionCensoredName: String
    let trackCensoredName: String
    let collectionViewURL: String
    let feedURL: String
    let trackViewURL: String
    let artworkUrl30, artworkUrl60, artworkUrl100: String?
    let collectionPrice, trackPrice, collectionHDPrice: Double
    let releaseDate: String
    let collectionExplicitness, trackExplicitness: String
    let trackCount: Int
    let trackTimeMillis: Int?
    let country: String
    let currency: String
    let primaryGenreName: String
    let contentAdvisoryRating: String?
    let artworkUrl600: String
    let genreIDS, genres: [String]
    let artistID: Int?
    let artistViewURL: String?

    enum CodingKeys: String, CodingKey {
        case wrapperType, kind
        case collectionID = "collectionId"
        case trackID = "trackId"
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case collectionViewURL = "collectionViewUrl"
        case feedURL = "feedUrl"
        case trackViewURL = "trackViewUrl"
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice
        case collectionHDPrice = "collectionHdPrice"
        case releaseDate, collectionExplicitness, trackExplicitness, trackCount, trackTimeMillis, country, currency, primaryGenreName, contentAdvisoryRating, artworkUrl600
        case genreIDS = "genreIds"
        case genres
        case artistID = "artistId"
        case artistViewURL = "artistViewUrl"
    }
}
