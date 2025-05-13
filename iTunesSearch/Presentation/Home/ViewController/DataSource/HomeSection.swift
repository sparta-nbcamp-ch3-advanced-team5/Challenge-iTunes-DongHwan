//
//  HomeSection.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

enum HomeSection: Int, CaseIterable {
    /// 봄 Best
    case springBest
    /// 여름
    case summer
    /// 가을
    case fall
    /// 겨울
    case winter
    
    var title: String {
        switch self {
        case .springBest:
            return "봄 Best"
        case .summer:
            return "여름"
        case .fall:
            return "가을"
        case .winter:
            return "겨울"
        }
    }
    
    var subtitle: String {
        switch self {
        case .springBest:
            return "봄에 어울리는 음악 Best 5"
        case .summer:
            return "여름에 어울리는 음악"
        case .fall:
            return "가을에 어울리는 음악"
        case .winter:
            return "겨울에 어울리는 음악"
        }
    }
}
