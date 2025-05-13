//
//  DataError.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

/// JSON 파싱 중 발생할 수 있는 에러 메세지
enum DataError: Error {
    case fileNotFound
    case parsingFailed
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "JSON 파일 없음"
        case .parsingFailed:
            return "JSON 파싱 에러"
        }
    }
}
