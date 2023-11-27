//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Chingiz on 04.10.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = AuthConfiguration.standard.authApiBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
