//
//  ProfileImage.swift
//  ImageFeed
//
//  Created by Chingiz on 15.11.2023.
//

import Foundation

struct ProfileImage: Codable {
    let profileImage: [String: String]
    
    init(decodedData: UserResult) {
        self.profileImage = decodedData.profileImage
    }
}
