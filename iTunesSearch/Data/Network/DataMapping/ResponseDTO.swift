//
//  ResponseDTO.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

struct ResponseDTO<T: Decodable>: Decodable {
    let resultCount: Int
    let results: [T]
}
