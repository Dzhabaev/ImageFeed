//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Chingiz on 29.09.2023.
//

import Foundation

// MARK: - OAuth2Service

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = makeRequest(code: code)
        let task = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(.success(""))
                self.task = nil
                if error != nil {
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

// MARK: - Private Methods

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
}
