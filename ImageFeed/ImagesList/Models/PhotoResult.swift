//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Chingiz on 09.11.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: CGFloat
    let height: CGFloat
    let likedByUser: Bool?
    let description: String?
    let urls: UrlsResult?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}
