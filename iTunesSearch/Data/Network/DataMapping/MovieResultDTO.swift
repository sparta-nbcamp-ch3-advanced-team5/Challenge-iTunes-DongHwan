//
//  MovieResultDTO.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct MovieResultDTO: Decodable {
    let wrapperType: String
    let kind: String
    let collectionID: Int?
    let trackID: Int
    let artistName: String
    let collectionName: String?
    let trackName: String
    let collectionCensoredName: String?
    let trackCensoredName: String
    let collectionArtistID: Int?
    let collectionArtistViewURL, collectionViewURL: String?
    let trackViewURL: String
    let previewURL: String
    let artworkUrl30, artworkUrl60, artworkUrl100: String
    let collectionPrice, trackPrice, trackRentalPrice, collectionHDPrice: Double
    let trackHDPrice, trackHDRentalPrice: Double
    let releaseDate: String
    let collectionExplicitness, trackExplicitness: String
    let discCount, discNumber, trackCount, trackNumber: Int?
    let trackTimeMillis: Int
    let country: String
    let currency: String
    let primaryGenreName: String
    let contentAdvisoryRating: String
    let shortDescription: String?
    let longDescription: String
    let hasITunesExtras: Bool?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType, kind
        case collectionID = "collectionId"
        case trackID = "trackId"
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case collectionArtistID = "collectionArtistId"
        case collectionArtistViewURL = "collectionArtistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice, trackRentalPrice
        case collectionHDPrice = "collectionHdPrice"
        case trackHDPrice = "trackHdPrice"
        case trackHDRentalPrice = "trackHdRentalPrice"
        case releaseDate, collectionExplicitness, trackExplicitness, discCount, discNumber, trackCount, trackNumber, trackTimeMillis, country, currency, primaryGenreName, contentAdvisoryRating, shortDescription, longDescription, hasITunesExtras
    }
}

extension MovieResultDTO {
    func toModel() -> MovieResultModel {
        return MovieResultModel(artistName: artistName,
                                collectionName: collectionName,
                                trackName: trackName,
                                collectionArtistViewURL: collectionArtistViewURL,
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
                                shortDescription: shortDescription,
                                longDescription: longDescription,
                                hasITunesExtras: hasITunesExtras,
                                backgroundArtistImageColorHex: BackgroundColorsHex.allCases.randomElement()!.rawValue)
    }
}
