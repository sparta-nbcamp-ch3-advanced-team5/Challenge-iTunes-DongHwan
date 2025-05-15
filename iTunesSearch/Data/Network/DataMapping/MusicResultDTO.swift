//
//  MusicResultDTO.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

// MARK: - Result
struct MusicResultDTO: Decodable {
    let wrapperType: String
    let kind: String
    let artistID: Int
    let collectionID: Int?
    let trackID: Int
    let artistName: String
    let collectionName: String?
    let trackName: String
    let collectionCensoredName: String?
    let trackCensoredName: String
    let artistViewURL: String
    let collectionViewURL: String?
    let trackViewURL: String
    let previewURL: String
    let artworkUrl30, artworkUrl60, artworkUrl100: String
    let collectionPrice, trackPrice: Double
    let releaseDate: String
    let collectionExplicitness, trackExplicitness: String
    let discCount, discNumber, trackCount, trackNumber: Int?
    let trackTimeMillis: Int
    let country: String
    let currency: String
    let primaryGenreName: String
    let isStreamable: Bool?
    let collectionArtistID: Int?
    let collectionArtistName: String?
    let collectionArtistViewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType, kind
        case artistID = "artistId"
        case collectionID = "collectionId"
        case trackID = "trackId"
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice, releaseDate, collectionExplicitness, trackExplicitness, discCount, discNumber, trackCount, trackNumber, trackTimeMillis, country, currency, primaryGenreName, isStreamable
        case collectionArtistID = "collectionArtistId"
        case collectionArtistName
        case collectionArtistViewURL = "collectionArtistViewUrl"
    }
}

extension MusicResultDTO {
    func toModel() -> MusicResultModel {
        return MusicResultModel(artistName: artistName,
                                collectionName: collectionName,
                                trackName: trackName,
                                artistViewURL: artistViewURL,
                                collectionViewURL: collectionViewURL,
                                trackViewURL: trackViewURL,
                                previewURL: previewURL,
                                artworkUrl100: artworkUrl100,
                                releaseDate: releaseDate,
                                discCount: discCount,
                                discNumber: discNumber,
                                trackCount: trackCount,
                                trackNumber: trackNumber,
                                trackTimeMillis: trackTimeMillis,
                                primaryGenreName: primaryGenreName,
                                collectionArtistName: collectionArtistName,
                                collectionArtistViewURL: collectionViewURL,
                                backgroundArtistImageColorHex: BackgroundColorsHex.allCases.randomElement()!.rawValue)
    }
}
