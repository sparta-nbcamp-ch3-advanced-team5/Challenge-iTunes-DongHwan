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
    let artistID: Int?
    let collectionID, trackID: Int
    let artistName, collectionName, trackName, collectionCensoredName: String
    let trackCensoredName: String
    let artistViewURL: String?
    let collectionViewURL: String
    let feedURL: String?
    let trackViewURL: String
    let artworkUrl30, artworkUrl60, artworkUrl100: String
    let collectionPrice, trackPrice, collectionHDPrice: Int
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
    
    enum CodingKeys: String, CodingKey {
        case wrapperType, kind
        case artistID = "artistId"
        case collectionID = "collectionId"
        case trackID = "trackId"
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case feedURL = "feedUrl"
        case trackViewURL = "trackViewUrl"
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice
        case collectionHDPrice = "collectionHdPrice"
        case releaseDate, collectionExplicitness, trackExplicitness, trackCount, trackTimeMillis, country, currency, primaryGenreName, contentAdvisoryRating, artworkUrl600
        case genreIDS = "genreIds"
        case genres
    }
}

extension PodcastResultDTO {
    func toModel() -> PodcastResultModel {
        return PodcastResultModel(artistName: artistName,
                                  collectionName: collectionName,
                                  trackName: trackName,
                                  artistViewURL: artistViewURL,
                                  collectionViewURL: collectionViewURL,
                                  feedURL: feedURL,
                                  trackViewURL: trackViewURL,
                                  artworkUrl100: artworkUrl100,
                                  releaseDate: releaseDate,
                                  trackCount: trackCount,
                                  trackTimeMillis: trackTimeMillis,
                                  primaryGenreName: primaryGenreName,
                                  artworkUrl600: artworkUrl600)
    }
}
