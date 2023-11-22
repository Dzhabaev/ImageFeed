//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Chingiz on 27.09.2023.
//

import Foundation

let AccessKey = "sG3qXc7av5XKG9kGLbn52zXkJvLyqjl_QqafuylvlDY"
let SecretKey = "qryNLTtJnejKrNvRxZ1zHe4od70mMcPNxRup5LzIb98"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let BaseURL = URL(string: "https://unsplash.com/")!

let ApiBaseURL = URL(string: "https://api.unsplash.com/")!
let AuthorizeURL = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let baseURL: URL
    let apiBaseURL: URL
    let authorizeURL: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, baseURL: URL, apiBaseURL: URL, authorizeURL: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.baseURL = baseURL
        self.apiBaseURL = apiBaseURL
        self.authorizeURL = authorizeURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 baseURL: BaseURL,
                                 apiBaseURL: ApiBaseURL,
                                 authorizeURL: AuthorizeURL)
    }
}
