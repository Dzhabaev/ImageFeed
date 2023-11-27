//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Chingiz on 29.09.2023.
//

import Foundation

// MARK: - OAuth2Service
final class OAuth2Service {
    
    // MARK: - Properties
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage.shared.token
        }
        set {
            OAuth2TokenStorage.shared.token = newValue
        }
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code {return}
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let session = URLSession.shared
        let task = session.objectTask(for: request) {[weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else {return}
            switch result {
            case .success(let decodedObject):
                let authToken = decodedObject.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.task = nil
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

// MARK: - Auth Token Request Extension
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        let configuration = AuthConfiguration.standard
        let baseURL = configuration.authBaseURL
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(configuration.authAccessKey)"
            + "&&client_secret=\(configuration.authSecretKey)"
            + "&&redirect_uri=\(configuration.authRedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: baseURL
        )
    }
}
