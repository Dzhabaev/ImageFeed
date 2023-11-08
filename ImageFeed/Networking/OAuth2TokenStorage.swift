//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Chingiz on 29.09.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init(){}
    private let keychainWrapper = KeychainWrapper.standard
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return keychainWrapper.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                keychainWrapper.set(newValue, forKey: tokenKey)
            } else {
                keychainWrapper.removeObject(forKey: tokenKey)
            }
        }
    }
}
