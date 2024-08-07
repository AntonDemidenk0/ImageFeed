//
//  Image Result.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 31.7.24..
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let created_at: String?
    let description: String?
    let liked_by_user: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case created_at
        case description
        case liked_by_user
        case urls
    }
}
struct  UrlsResult: Codable {
    let full: String
    let thumb: String
}


