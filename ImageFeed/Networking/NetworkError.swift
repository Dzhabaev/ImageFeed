//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Chingiz on 04.10.2023.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case codeError
}
