//
//  DateFormatter+Extension.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/15/25.
//

import Foundation

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    static func getYearFromISO(from string: String) -> String {
        let isoDate = dateFormatter.date(from: string)
        dateFormatter.dateFormat = "yyyy년"
        return dateFormatter.string(from: isoDate ?? .now)
    }
}
