//
//  ImageCacheInfoDTO.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

struct ImageCacheInfoDTO: Codable {
    let urlString: String
    let date: Date
    
    func updateDate() -> Self {
        .init(urlString: urlString, date: .now)
    }
}
