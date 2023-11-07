//
//  Constants.swift
//  ImageFeed
//
//  Created by Chingiz on 27.09.2023.
//

import Foundation

struct Constants {
    static let accessKey = "sG3qXc7av5XKG9kGLbn52zXkJvLyqjl_QqafuylvlDY"
    static let secretKey = "qryNLTtJnejKrNvRxZ1zHe4od70mMcPNxRup5LzIb98"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let baseURL = URL(string: "https://unsplash.com/")!
    static let apiBaseURL = URL(string: "https://api.unsplash.com/")!
    static let authorizeURL = "https://unsplash.com/oauth/authorize"
}
