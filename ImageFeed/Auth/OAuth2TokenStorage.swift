//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Chingiz on 29.09.2023.
//

import Foundation

class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
