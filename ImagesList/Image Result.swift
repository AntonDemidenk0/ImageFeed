//
//  Image Result.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 31.7.24..
//

import Foundation

struct ImageResult: Codable {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let created_at: Date?
    let description: String?
    let liked_by_user: Bool
    let imageUrls: ImageUrls
}

struct  ImageUrls: Codable {
    let full: String
    let thumb: String
}


