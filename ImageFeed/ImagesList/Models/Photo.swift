//
//  Photo.swift
//  ImageFeed
//
//  Created by Chingiz on 09.11.2023.
//

import Foundation

struct Photo {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
