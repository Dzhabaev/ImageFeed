//
//  Profile.swift
//  ImageFeed
//
//  Created by Chingiz on 07.11.2023.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(decodedData: ProfileResult) {
        self.username = decodedData.username
        let firstName = decodedData.firstName
        let lastName = decodedData.lastName ?? ""
        self.name = firstName.isEmpty ? lastName : (firstName + " " + lastName)
        self.loginName = "@" + decodedData.username
        self.bio = decodedData.bio
    }
}
