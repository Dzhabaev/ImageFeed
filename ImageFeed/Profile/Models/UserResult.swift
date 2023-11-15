//
//  UserResult.swift
//  ImageFeed
//
//  Created by Chingiz on 15.11.2023.
//

import Foundation

struct UserResult: Codable {
    let profileImage: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
