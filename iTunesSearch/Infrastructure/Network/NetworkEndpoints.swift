//
//  NetworkEndpoints.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import Foundation

enum NetworkEndpoints: String {
    //    https://itunes.apple.com/search?term=봄&media=music&limit=25
    //    https://itunes.apple.com/search?term=Marvel&media=movie&limit=25
    //    https://itunes.apple.com/search?term=Marvel&media=podcast&limit=25
    
    case baseURL = "https://itunes.apple.com/search"
    
    static func urlRequest(_ baseURL: Self, term: String, mediaType: MediaType, limit: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(baseURL.rawValue)") else {
            return nil
        }
        
        var queryItemArr = [URLQueryItem]()
        queryItemArr.append(URLQueryItem(name: "term", value: term))
        queryItemArr.append(URLQueryItem(name: "media", value: mediaType.rawValue))
        queryItemArr.append(URLQueryItem(name: "limit", value: String(limit)))
        urlComponents.queryItems = queryItemArr
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
}
