//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Chingiz on 27.09.2023.
//

import Foundation

let accessKey = "sG3qXc7av5XKG9kGLbn52zXkJvLyqjl_QqafuylvlDY"
let secretKey = "qryNLTtJnejKrNvRxZ1zHe4od70mMcPNxRup5LzIb98"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"
let baseURL = URL(string: "https://unsplash.com/")!
let apiBaseURL = URL(string: "https://api.unsplash.com/")!
let authorizeURL = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let authAccessKey: String
    let authSecretKey: String
    let authRedirectURI: String
    let authAccessScope: String
    let authBaseURL: URL
    let authApiBaseURL: URL
    let authAuthorizeURL: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, baseURL: URL, apiBaseURL: URL, authorizeURL: String) {
        self.authAccessKey = accessKey
        self.authSecretKey = secretKey
        self.authRedirectURI = redirectURI
        self.authAccessScope = accessScope
        self.authBaseURL = baseURL
        self.authApiBaseURL = apiBaseURL
        self.authAuthorizeURL = authorizeURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: accessKey,
                                 secretKey: secretKey,
                                 redirectURI: redirectURI,
                                 accessScope: accessScope,
                                 baseURL: baseURL,
                                 apiBaseURL: apiBaseURL,
                                 authorizeURL: authorizeURL)
    }
}
