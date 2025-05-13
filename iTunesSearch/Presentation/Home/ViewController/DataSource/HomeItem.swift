//
//  HomeItem.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

enum HomeItem: Hashable {
    /// 봄 Best Item
    case best(MusicResultModel)
    /// 여름, 가을, 겨울 Item
    case season(MusicResultModel)
}
