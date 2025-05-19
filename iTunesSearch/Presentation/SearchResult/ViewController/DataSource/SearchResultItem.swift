//
//  SearchResultItem.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import Foundation

enum SearchResultItem: Hashable {
    case searchText(String)
    case podcast(PodcastResultModel)
    case movieList(MovieResultModel)
    case loading
}
