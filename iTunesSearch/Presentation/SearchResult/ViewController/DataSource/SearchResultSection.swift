//
//  SearchResultSection.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import Foundation

enum SearchResultSection: Hashable {
    case searchText
    case largeBanner(page: Int)
    case list(page: Int)
    case loading
}
